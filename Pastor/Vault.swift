//
//  Vault.swift
//  Pastor
//
//  Created by Abhi Beckert on 2021-08-31.
//
//  A Pastor Vault is a local directory containing the current state of the vault, and the full list of writes necessary
//  to reach the current state. Writes are synced across devices via Apple's CloudKit framework to sync the vault across
//  all devices owned by the user (and in future, anyone they have shared the vault with).
//
//  The current state and also each write is a json file with the exception of attachments, which are stored in an
//  attachments directory as binary data. All files are encrypted using a key derived from the vault password.
//
//  There are no recovery options. If the password is forgotten, the contents of the vault is lost.
//
//  Example directory structure:
//     Vault.pastor/current-state.json
//     Vault.pastor/attachments/3af71201-0483-492e-b6df-edef50d5053d
//     Vault.pastor/writes/2042/10/02/14-10-42-f2f94035-db43-4401-93d3-a6223d1c7343.json
//     Vault.pastor/writes/2042/10/02/14-10-42-f2f94035-db43-4401-93d3-a6223d1c7343-attachments/3af71201-0483-492e-b6df-edef50d5053d
//

import Foundation

class Vault
{
  let dir: VaultDir
  
  let id: UUID
  let name: String
  let items: [VaultItemEncryptedRecord]
  
  init(dir: VaultDir) throws {
    self.dir = dir
    
    let currentStateData = try dir.read(path: "current-state.json")
    let currentState = try JSONDecoder().decode(VaultCurrentStateRecord.self, from: currentStateData)
    self.id = UUID(uuidString: currentState.id)!
    self.name = currentState.name
    self.items = currentState.items
  }
  
  func unlock(password: String) throws
  {
    // todo: unlock the vault. Throw on incorrect password. Until the vault has been unlocked, all read/write attempts will throw
  }
  
  func fetchItemIds() throws -> [UUID]
  {
    throw VaultError.unknownError
  }
  
  func fetchItem(id: UUID) throws -> VaultItem
  {
    throw VaultError.unknownError
  }
  
  func fetchAttachmentData(attachment: VaultItemAttachmentValue) throws -> Data
  {
    throw VaultError.unknownError
  }
  
  func addItem(item: VaultItem) throws
  {
    
  }
  
  func removeItem(item: VaultItem) throws
  {
    
  }
  
  func renameItem(item: VaultItem, newName: String) throws
  {
    
  }
  
  func addItemValue(item: VaultItem, value: VaultItemValue) throws
  {
    
  }
  
  func removeItemValue(item: VaultItem, value: VaultItemValue) throws
  {
    
  }
  
  func updateItemValue(item: VaultItem, updatedValue: VaultItemValue) throws
  {
    
  }
  
  func addAttachment(item: VaultItem, attachment: VaultItemAttachmentValue, data: Data) throws
  {
    
  }
  
  func updateAttachmentData(item: VaultItem, attachment: VaultItemAttachmentValue, data: Data) throws
  {
    
  }
}

enum VaultError: Error
{
  case vaultLockedError
  case readError
  case writeError
  case unknownError
}

struct VaultItem
{
  let id: UUID
  var name: String
  var values: [VaultItemValue]
  
  init(id: UUID, name: String, values: [VaultItemValue]) {
    self.id = id
    self.name = name
    self.values = values
  }
}

protocol VaultItemValue
{
  var id: UUID { get }
  var name: String { get set }
}

struct VaultItemStringValue: VaultItemValue
{
  var id: UUID
  var name: String
  var value: String
}

struct VaultItemPasswordValue: VaultItemValue
{
  var id: UUID
  var name: String
  var value: String
}

struct VaultItemTOTPValue: VaultItemValue
{
  var id: UUID
  var name: String
  var seed: Data
}

struct VaultItemAttachmentValue: VaultItemValue
{
  var id: UUID
  var name: String
}

class VaultDir
{
  let dir: URL
  let fman: FileManager
  
  init(dir: URL) {
    self.dir = dir
    self.fman = FileManager.default
  }
  
  func read(path: String) throws -> Data
  {
    let url = dir.appendingPathComponent(path)
    return try Data(contentsOf: url)
  }
  
  func write(path: String, data: Data) throws
  {
    let url = dir.appendingPathComponent(path)
    try data.write(to: url, options: .atomicWrite)
  }
  
  func remove(path: String) throws
  {
    let url = dir.appendingPathComponent(path)
    return try self.fman.removeItem(at: url)
  }
  
  func list(path: String?) -> [String]
  {
    let url: URL
    if let path = path {
      url = dir.appendingPathComponent(path)
    } else {
      url = dir
    }
    
    guard let dirEnum = self.fman.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey]) else {
      return []
    }
    
    var results: [String] = []
    for case let child as URL in dirEnum {
      results.append(child.lastPathComponent)
    }
    return results
  }
}

/**
 * Structure of the "current state" json file in a vault
 */
struct VaultCurrentStateRecord: Codable {
  let id: String
  let version: String
  let name: String
  let items: [VaultItemEncryptedRecord]
}

/**
 * Structure of a record in a vault (encrypted)
 */
struct VaultItemEncryptedRecord: Codable {
  let id: String
  let version: String
  let nonce: String
  let contents: String
}
