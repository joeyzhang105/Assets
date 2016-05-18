using UnityEditor;
using UnityEngine;
using System.IO;

public class ExportAssetBundles {

	[MenuItem("Assets/Build AssetBundle From Selection")]
	static void ExportResourceNoTrack () {
		// Bring up save panel
		string path = EditorUtility.SaveFilePanel ("Save Resource", "", "New Resource", "unity3d");
		if (path.Length != 0) {
			// Build the resource file from the active selection.
			BuildPipeline.BuildAssetBundle(Selection.activeObject, Selection.objects, path,/*BuildAssetBundleOptions.UncompressedAssetBundle|*/BuildAssetBundleOptions.CollectDependencies);
		}
	}
}
