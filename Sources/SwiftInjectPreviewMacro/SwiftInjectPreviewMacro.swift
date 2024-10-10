import Foundation
#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftOperators
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

@main
struct InjectPreviewMacrosPlugin: CompilerPlugin {

	let providingMacros: [Macro.Type] = [
		InjectUIViewPreviewMacro.self,
		InjectUIKitViewPreviewMacro.self,
		InjectAppKitViewPreviewMacro.self,
		InjectUIViewControllerPreviewMacro.self,
		InjectNSViewPreviewMacro.self,
		InjectNSViewControllerPreviewMacro.self
	]
}

public struct InjectUIViewPreviewMacro: DeclarationMacro {

	public static func expansion(
		of node: some FreestandingMacroExpansionSyntax,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		let (name, statement) = try nameAndStatement(of: node, in: context)
		var result: [DeclSyntax] = [
			"""
			#if DEBUG
			final class \(name) {

			    @objc class func injected() {
					\(raw: uiWindowCode)

			        window?.rootViewController = WrapperViewController {
			            \(statement)
			        }
			    }

			    private final class WrapperViewController: UIViewController {

			      let content: UIView

			      init(_ content: @MainActor () -> UIView) {
			          self.content = content()
			          super.init(nibName: nil, bundle: nil)
			      }

			      required init?(coder: NSCoder) {
			          fatalError("init(coder:) has not been implemented")
			      }

			      override func loadView() {
			          view = content
			      }
			    }
			}
			#endif
			""",
		]
		if context.column(of: node) > 1 {
			result += [
				.previewsVar,
				.previewsStruct(statement),
				representable(uiKit: true, controller: false)
			]
		}
		return result
	}
}

public struct InjectAppKitViewPreviewMacro: DeclarationMacro {
	
	public static func expansion(
		of node: some FreestandingMacroExpansionSyntax,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		try swiftUIMacro(iOS: false, of: node, in: context)
	}
}

public struct InjectUIKitViewPreviewMacro: DeclarationMacro {
	
	public static func expansion(
		of node: some FreestandingMacroExpansionSyntax,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		try swiftUIMacro(iOS: true, of: node, in: context)
	}
}

public struct InjectUIViewControllerPreviewMacro: DeclarationMacro {

	public static func expansion(
		of node: some FreestandingMacroExpansionSyntax,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		let (name, statement) = try nameAndStatement(of: node, in: context)
		var result: [DeclSyntax] = [
			"""
			#if DEBUG
			final class \(name) {

			    @objc class func injected() {
			     \(raw: uiWindowCode)

			      window?.rootViewController = {
			          \(statement)
			      }()
			    }
			}
			#endif
			""",
		]
		if context.column(of: node) > 1 {
			result += [
				.previewsVar,
				.previewsStruct(statement),
				representable(uiKit: true, controller: true)
			]
		}
		return result
	}
}

public struct InjectNSViewPreviewMacro: DeclarationMacro {
	
	public static func expansion(
		of node: some FreestandingMacroExpansionSyntax,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		let (name, statement) = try nameAndStatement(of: node, in: context)
		var result: [DeclSyntax] = [
		"""
		#if DEBUG
		final class \(name) {
		
			@objc class func injected() {
		        \(raw: nsWindowCode)

		        previewWindow.contentViewController = WrapperViewController {
		        \(statement)
		        }
		        previewWindow.makeKeyAndOrderFront(nil)
			}

		    private final class WrapperViewController: NSViewController {

		        let content: NSView

		        init(_ content: @MainActor () -> NSView) {
		            self.content = content()
		            super.init(nibName: nil, bundle: nil)
		        }
		
		        required init?(coder: NSCoder) {
		            fatalError("init(coder:) has not been implemented")
		        }
		
		        override func loadView() {
		            view = content
		        }
		    }
		}
		#endif
		""",
		]
		if context.column(of: node) > 1 {
			result += [
				.previewsVar,
				.previewsStruct(statement),
				representable(uiKit: false, controller: false)
			]
		}
		return result
	}
}

public struct InjectNSViewControllerPreviewMacro: DeclarationMacro {
	
	public static func expansion(
		of node: some FreestandingMacroExpansionSyntax,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		let (name, statement) = try nameAndStatement(of: node, in: context)
		var result: [DeclSyntax] = [
	"""
	#if DEBUG
	final class \(name) {
	
	   @objc class func injected() {
		 \(raw: nsWindowCode)
	
	     previewWindow.contentViewController = {
			 \(statement)
		 }()
	     previewWindow.makeKeyAndOrderFront(nil)
	   }
	}
	#endif
	""",
		]
		if context.column(of: node) > 1 {
			result += [
				.previewsVar,
				.previewsStruct(statement),
				representable(uiKit: false, controller: true)
			]
		}
		return result
	}
}

private func swiftUIMacro(
	iOS: Bool,
	of node: some FreestandingMacroExpansionSyntax,
	in context: some MacroExpansionContext
) throws -> [DeclSyntax] {
	var (name, statement) = try nameAndStatement(of: node, in: context)
	var perviewable: CodeBlockItemListSyntax = ""
	if statement.last?.item.is(ReturnStmtSyntax.self) == true {
		var i = statement.startIndex
		while i < statement.endIndex {
			if var variable = statement[i].item.as(VariableDeclSyntax.self), !variable.attributes.isEmpty {
				var value = statement.remove(at: i)
				if let j = variable.attributes.firstIndex(where: { $0.as(AttributeSyntax.self)?.attributeName.trimmed.description == "Previewable" }) {
					variable.attributes.remove(at: j)
					value.item = CodeBlockItemSyntax.Item(variable)
				}
				perviewable.append(value)
			} else {
				i = statement.index(after: i)
			}
		}
	}
	let injected = iOS ?
		"""
		\(uiWindowCode)
		         window?.rootViewController = UIHostingController(rootView: previews)
		"""
	:
		"""
		\(nsWindowCode)
		        previewWindow.contentViewController = NSHostingController(rootView: previews)
		        previewWindow.makeKeyAndOrderFront(nil)
		"""
	var result: [DeclSyntax] = [
	"""
	#if DEBUG
	final class \(name) {

		@objc class func injected() {
		\(raw: injected)
		}
	}
	#endif
	"""
	]
	if context.column(of: node) > 1 {
		result += [
			.previewsVar,
		"""
	 	struct Previews: View {
	 	\(perviewable)
	 		var body: some View {
	 	 	\(statement)
	 	 	}
	 	}
	 	"""
		]
	}
	return result
}

private let uiWindowCode = """
let window = UIApplication.shared.connectedScenes
        .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
        .first(where: \\.isKeyWindow)
"""

private let nsWindowCode = """
let title = "Injected Preview"
        let previewWindow = NSApp.windows.first(where: { $0.title == title }) ?? NSWindow(
            contentRect: NSMakeRect(0, 0, 800, 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        previewWindow.center()
        previewWindow.title = title
"""

private func nameAndStatement(
	of node: some FreestandingMacroExpansionSyntax,
	in context: some MacroExpansionContext
) throws -> (TokenSyntax, CodeBlockItemListSyntax) {
	guard
		let closureExpr = node.trailingClosure,
		!closureExpr.statements.isEmpty
	else {
		throw SimpleError("Expected a single closure expression")
	}
	let statement = closureExpr.statements
	return (context.makeUniqueName("Preview"), statement)
}

#endif

private func representable(
	uiKit: Bool,
	controller: Bool
) -> DeclSyntax {
	let upPrefix = uiKit ? "UI" : "NS"
	let lowPrefix = uiKit ? "ui" : "ns"
	let cntr = controller ? "Controller" : ""
	let sizeThatFits =
"""
	@available(iOS 16.0, tvOS 16.0, *)
	func sizeThatFits(_ proposal: ProposedViewSize, uiView\(cntr): T, context: Context) -> CGSize? {
		\(controller ? "let uiView: UIView = uiView\(cntr).view" : "")
  		let size = CGSize(
   			width: proposal.width ?? .infinity,
   			height: proposal.height ?? .infinity
		)
		if !uiView.constraints.isEmpty {
			return uiView.systemLayoutSizeFitting(size)
		} else {
			let intrinsic = uiView.intrinsicContentSize
			if
				proposal == .unspecified,
				intrinsic.width != UIView.noIntrinsicMetric,
				intrinsic.height != UIView.noIntrinsicMetric {
				return intrinsic
			}
				return uiView.sizeThatFits(size)
		}
	}
"""

	return
"""
private struct Representable<T: \(raw: upPrefix)View\(raw: cntr)>: \(raw: upPrefix)View\(raw: cntr)Representable {

	let create: () -> T

	func make\(raw: upPrefix)View\(raw: cntr)(context: Context) -> T {
		create()
	}

	func update\(raw: upPrefix)View\(raw: cntr)(_ \(raw: lowPrefix)View\(raw: cntr): T, context: Context) {}
\(raw: uiKit ? sizeThatFits : "")
}
"""
}

private extension DeclSyntax {

	static var previewsVar: DeclSyntax {
		"""
		static var previews: Previews {
			Previews()
		}
		"""
	}

	static func previewsStruct(_ statement: CodeBlockItemListSyntax) -> DeclSyntax {
   		"""
   		struct Previews: View {
   			var body: some View {
   				Representable {
   				\(statement)
   				}
   			}
   		}
   		"""
	}
}

extension MacroExpansionContext {
	
	func column(of node: some SyntaxProtocol) -> Int {
		Int(location(of: node)?.column.as(IntegerLiteralExprSyntax.self)?.literal.text ?? "") ?? 1
	}
}

private struct SimpleError: LocalizedError, CustomStringConvertible {
	var description: String
	var errorDescription: String? { description }
	init(_ description: String) {
		self.description = description
	}
}
