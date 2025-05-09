//
//  APIEndpoint.swift
//  Space S
//
//  Created by 김재현 on 5/9/25.
//

struct APIEndpoints {
    static let baseURL = "https://api.example.com" // 기본 URL
    
    // 엔드포인트들
    static let fetchUsers = "\(baseURL)/users"
    static let fetchPosts = "\(baseURL)/posts"
    static let fetchComments = "\(baseURL)/comments"
    
    // 예를 들어, 인증 관련 엔드포인트
    static let login = "\(baseURL)/login"
    static let register = "\(baseURL)/register"
}
