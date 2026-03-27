import Testing
@testable import Critic

@Test func criticSharedInstanceExists() {
    let instance = Critic.shared
    #expect(instance != nil)
}

@Test func criticAPIInitialization() throws {
    let url = try #require(URL(string: "https://api.example.com"))
    let api = CriticAPI(baseURL: url)
    #expect(api.baseURL == url)
}

@Test func multipartFormDataContentType() {
    let formData = MultipartFormData(boundary: "test-boundary")
    #expect(formData.contentType == "multipart/form-data; boundary=test-boundary")
}

@Test func paginatedResponseDecoding() throws {
    let json = """
    {"items": [{"id": "1"}], "totalCount": 1}
    """
    let data = Data(json.utf8)
    let response = try JSONDecoder().decode(PaginatedResponse<App>.self, from: data)
    #expect(response.items.count == 1)
    #expect(response.totalCount == 1)
}

@Test func criticErrorCases() {
    let error = CriticError.unexpectedStatusCode(404)
    #expect(error is CriticError)

    let decodingError = CriticError.decodingFailed
    #expect(decodingError is CriticError)
}
