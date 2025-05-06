
import Dependencies

extension RemoteConfigClient: TestDependencyKey {
    public static var testValue: Self {
        Self()
    }
    
    public static var previewValue: Self {
        Self()
    }
}

extension RemoteConfigClient {
    public static let happyPath: Self = {
        return .init(
            editorChoices: {
                EditorChoice.all
            },
            photoSelectionLimitNumber: {
                20
            }
        )
    }()
}
