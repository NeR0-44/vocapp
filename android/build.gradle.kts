allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
subprojects {
    val subproject = this
    
    // Diese Funktion setzt den Namensraum, falls er fehlt
    val fixNamespace = {
        val android = subproject.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        if (android != null && android.namespace == null) {
            android.namespace = subproject.group.toString()
        }
    }

    // Wenn das Projekt schon fertig geladen ist, führen wir es sofort aus.
    // Ansonsten warten wir auf den 'afterEvaluate' Zeitpunkt.
    if (subproject.state.executed) {
        fixNamespace()
    } else {
        subproject.afterEvaluate {
            fixNamespace()
        }
    }
}