depandance yaml
  cloud_firestore: ^3.4.5
  firebase_messaging: ^12.0.3
  flutter_local_notifications: ^9.8.0+1
  firebase_core: ^1.21.0
  http: ^0.13.5
  ajouter ces ligne dans android/app/build.gradle
  apply plugin: 'com.google.gms.google-services'
  dependencies {
    ...
    implementation 'com.google.firebase:firebase-analytics'
    implementation platform('com.google.firebase:firebase-bom:30.3.2')

}
pour le firestore il faut ajouter ce code en dessous
    defaultConfig {
        ...
        multiDexEnabled true
    }

ajouter cette ligne en dessous dans android/build.gradle
    classpath 'com.google.gms:google-services:4.3.13'
