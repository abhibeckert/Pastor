//
//  PastorTests.swift
//  PastorTests
//
//  Created by Abhi Beckert on 2021-08-31.
//

import XCTest
@testable import Pastor

class MockVaultDir: VaultDir
{
  init()
  {
    super.init(dir: URL(string: "about:blank")!)
  }
  
  override func read(path: String) throws -> Data {
    switch path {
    case "current-state.json":
      return "{\"id\":\"ba64a896-47ff-4e5c-af5c-9461b71e9a48\",\"version\":\"1.0.0\",\"name\":\"My Vault\",\"items\":[{\"id\":\"40e44982-afc7-40fa-96c0-82ac4c11b8e0\",\"version\":\"1.0.0\",\"nonce\":\"abc\",\"contents\":\"def\"}]}".data(using: .utf8)!
    default:
      throw VaultError.readError
    }
  }
}

class PastorTests: XCTestCase {
  
  var vaultDir: MockVaultDir!
  var vault: Vault!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    
    vaultDir = MockVaultDir()
    vault = try! Vault(dir: vaultDir)
  }
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }
  
  func testVaultRead()
  {
    XCTAssertEqual(vault.id, UUID(uuidString: "ba64a896-47ff-4e5c-af5c-9461b71e9a48"))
    XCTAssertEqual(vault.name, "My Vault")
    XCTAssertEqual(vault.items.count, 1)
  }
  
}
