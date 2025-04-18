import Foundation

struct Executable {
	let configuration: ExecutableConfiguration

	func run(code: String) async throws -> String {
		// TODO: set process.currentDirectoryURL to either the input file or the output folder
		let runProcess = configuration.makeRunProcess()
		let (result, output) = try await runProcess(input: code, additionalArguments: [])

		let terminationStatus: RunProcess.TerminationStatus =
			switch result {
			case .right(let error):
				throw ExecutionFailure.processExecutionFailed(error, result)
			case .left(let status):
				status
			}

		let stringResult: String =
			switch output {
			case .data(let data):
				throw ExecutionFailure.processResultIsNotAString(data, terminationStatus)
			case .string(let string):
				string
			}

		return stringResult
	}
}
