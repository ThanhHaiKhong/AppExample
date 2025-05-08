//
//  SQLiteExplorationsApp.swift
//  SQLiteExplorations
//
//  Created by Thanh Hai Khong on 6/5/25.
//

import SwiftUI
import SQLite3

@main
struct SQLiteExplorationsApp: App {
	
	init() {
		let databasePath = URL.documentsDirectory.appendingPathComponent("db.sqlite").path()
		print("Database path: \(databasePath)")
		var db: OpaquePointer?
		guard sqlite3_open_v2(
			databasePath,
			&db,
			SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE,
			nil
		) == SQLITE_OK else {
			fatalError("Failed to open database")
		}
		
		guard sqlite3_exec(
			db,
			"""
			CREATE TABLE IF NOT EXISTS "players" (
				"id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE,
				"name" TEXT NOT NULL,
				"createAt" DATETIME NOT NULL
			)
			""",
			nil,
			nil,
			nil
		) == SQLITE_OK else {
			fatalError("Failed to create table")
		}
	}
	
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}
