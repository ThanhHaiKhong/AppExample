
import Dependencies
import RemoteConfigClient

extension RemoteConfigClient: DependencyKey {
    public static var liveValue: Self {
		let actor = RemoteConfigActor()
        return RemoteConfigClient(
			editorChoices: {
				try await actor.getEditorChoices()
			},
			photoSelectionLimitNumber: {
				try await actor.photoSelectionLimitNumber()
			}
        )
    }
}
