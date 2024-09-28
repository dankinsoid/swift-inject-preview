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
		InjectViewPreviewMacro.self,
		InjectUIViewControllerPreviewMacro.self,
	]
}

public struct InjectUIViewPreviewMacro: DeclarationMacro {

	public static func expansion(
		of node: some FreestandingMacroExpansionSyntax,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		let (name, statement) = try nameAndStatement(of: node, in: context)
		return [
			"""
			#if DEBUG
			final class \(name) {

			    @objc class func injected() {
			        let window = UIApplication.shared.connectedScenes
			            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
			            .first(where: \\.isKeyWindow)

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

			@available(iOS 17.0, macOS 14.10, tvOS 17.0, *)
			#Preview {
			    \(statement)
			}
			#endif
			""",
		]
	}
}

public struct InjectViewPreviewMacro: DeclarationMacro {

	public static func expansion(
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
		return [
			"""
			#if DEBUG
			final class \(name): PreviewProvider {

			    static var previews: Previews {
			      Previews()
			    }

			    @objc class func injected() {
			      let window = UIApplication.shared.connectedScenes
			          .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
			          .first(where: \\.isKeyWindow)

			      window?.rootViewController = UIHostingController(rootView: previews)
			    }

			struct Previews: View {
			\(perviewable)
			    var body: some View {
			        \(statement)
			        }
			    }
			}
			#endif
			""",
		]
	}
}

public struct InjectUIViewControllerPreviewMacro: DeclarationMacro {

	public static func expansion(
		of node: some FreestandingMacroExpansionSyntax,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		let (name, statement) = try nameAndStatement(of: node, in: context)
		return [
			"""
			#if DEBUG
			final class \(name) {

			    @objc class func injected() {
			      let window = UIApplication.shared.connectedScenes
			          .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
			          .first(where: \\.isKeyWindow)

			      window?.rootViewController = {
			          \(statement)
			      }()
			    }
			}

			@available(iOS 17.0, macOS 14.10, tvOS 17.0, *)
			#Preview {
			    \(statement)
			}
			#endif
			""",
		]
	}
}

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

private struct SimpleError: LocalizedError, CustomStringConvertible {
	var description: String
	var errorDescription: String? { description }
	init(_ description: String) {
		self.description = description
	}
}
