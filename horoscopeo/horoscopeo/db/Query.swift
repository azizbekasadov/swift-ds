public struct Query<T> {
    public var whereMatches: ((T) -> Bool)?
    public var sort: ((T, T) -> Bool)?
    public var limit: Int?
    public var offset: Int?

    public init(whereMatches: ((T) -> Bool)? = nil,
                sort: ((T, T) -> Bool)? = nil,
                limit: Int? = nil,
                offset: Int? = nil) {
        self.whereMatches = whereMatches
        self.sort = sort
        self.limit = limit
        self.offset = offset
    }
}