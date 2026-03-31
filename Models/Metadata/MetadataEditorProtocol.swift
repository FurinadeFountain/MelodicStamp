//
//  MetadataEditorProtocol.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/26.
//

import Foundation

struct MetadataEditingState: OptionSet {
    let rawValue: Int

    static let fine = MetadataEditingState(rawValue: 1 << 0)
    static let saving = MetadataEditingState(rawValue: 1 << 1)

    var isFine: Bool {
        switch self {
        case .fine:
            true
        default:
            false
        }
    }

    var isSaving: Bool {
        switch self {
        case .saving:
            true
        default:
            false
        }
    }
}

@MainActor protocol MetadataEditorProtocol: Modifiable {
    var metadataSet: Set<Metadata> { get }
    var hasMetadata: Bool { get }
    var state: MetadataEditingState { get }
}

extension MetadataEditorProtocol {
    var hasMetadata: Bool { !metadataSet.isEmpty }

    var state: MetadataEditingState {
        guard hasMetadata else { return [] }

        var result: MetadataEditingState = []
        let states = metadataSet.map(\.state)

        for state in states {
            switch state {
            case .fine:
                result.formUnion(.fine)
            case .saving:
                result.formUnion(.saving)
            default:
                break
            }
        }

        return result
    }

    @MainActor func restoreAll() {
        metadataSet.forEach { $0.restore() }
    }

    func updateAll(completion: (() -> ())? = nil) {
        Task {
            await withTaskGroup(of: Void.self) { group in
                for metadata in metadataSet {
                    group.addTask {
                        try? await metadata.update()
                    }
                }
            }
            await MainActor.run { completion?() }
        }
    }

    func writeAll(completion: (() -> ())? = nil) {
        Task {
            await withTaskGroup(of: Void.self) { group in
                for metadata in metadataSet {
                    group.addTask {
                        try? await metadata.write()
                    }
                }
            }
            await MainActor.run { completion?() }
        }
    }
}

extension MetadataEditorProtocol {
    var isModified: Bool {
        metadataSet.contains(where: \.isModified)
    }
}
