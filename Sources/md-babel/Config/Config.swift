import ArgumentParser
import Foundation

struct ConfigCommand: ParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "config",
		subcommands: [DumpCommand.self],
		// defaultSubcommand: DumpCommand.self,
		aliases: ["configure", "configuration"]
	)
}

extension ConfigCommand {
	struct DumpCommand: ParsableCommand {
		static let configuration = CommandConfiguration(
			commandName: "dump",
			abstract: "Inspect your effective configuration"
		)

		@Flag(
			name: .customLong("load-user-config"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: ArgumentHelp(
				"Whether to load the user's global config file.",
				discussion:
					"Disabling the global user configuration without setting --config will result in no context being recognized."
			)
		)
		var loadUserConfig = true

		// MARK: - Config File

		@Option(
			name: .customLong("config"),
			help: "Config file path.",
			transform: { URL(fileURLWithPath: $0) }
		)
		var configFile: URL?

		func executableRegistry() throws -> ExecutableRegistry {
			let fromXDG: [String: ExecutableConfiguration] =
				if loadUserConfig {
					(try? ExecutableConfiguration.configurations(jsonFileAtURL: xdgConfigURL)) ?? [:]
				} else {
					[:]
				}
			let fromFile = try configFile.map(ExecutableConfiguration.configurations(jsonFileAtURL:)) ?? [:]

			var configurations: [String: ExecutableConfiguration] = [:]
			configurations.merge(fromXDG) { _, new in new }
			configurations.merge(fromFile) { _, new in new }

			return ExecutableRegistry(configurations: configurations)
		}

		func run() throws {
			let registry = try executableRegistry()
			let json = try registry.json()
			let data = try json.data(formatting: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
			FileHandle.standardOutput.write(data)
		}
	}
}
