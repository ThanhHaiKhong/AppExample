
import Dependencies
import RemoteConfigClient

extension RemoteConfigClient: DependencyKey {
    public static var liveValue: Self {
        return Self(
            editorChoices: Configurator.shared.getEditorChoices,
            photoSelectionLimitNumber: Configurator.shared.photoSelectionLimitNumber
        )
    }
}
