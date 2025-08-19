@MainActor
public final class Store<State, Intent, Environment>: ObservableObject {
    @Published public private(set) var state: State

    public typealias Reducer = (_ state: inout State, _ intent: Intent, _ env: Environment) async -> Void

    private let reducer: Reducer
    public let env: Environment

    public init(initial: State, env: Environment, reducer: @escaping Reducer) {
        self.state = initial
        self.env = env
        self.reducer = reducer
    }

    public func send(_ intent: Intent) {
        Task { [weak self] in
            guard let self else { return }
            await self.reducer(&self.state, intent, self.env)
        }
    }
}