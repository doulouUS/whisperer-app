//
//  File.swift
//  Playground
//
//  Created by Louis DOUGE on 21/5/23.
//

import Foundation


struct ErrorWrapper: Identifiable {

    let id: UUID

    let error: Error

    let guidance: String


    init(id: UUID = UUID(), error: Error, guidance: String) {

        self.id = id

        self.error = error

        self.guidance = guidance

    }

}
