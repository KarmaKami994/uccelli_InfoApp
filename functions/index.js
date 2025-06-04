// Die Firebase Admin SDK, um auf Firestore zuzugreifen.
const admin = require('firebase-admin');
// Die Cloud Functions for Firebase SDK.
const functions = require('firebase-functions');
// Axios für HTTP-Anfragen
const axios = require('axios');


// Initialisiere Firebase Admin SDK
admin.initializeApp(); // Standard-Initialisierung

// >>> DEBUG-LOGS START - Nach admin.initializeApp() <<<
console.log("--- Debug nach admin.initializeApp() ---");
console.log("Type of admin:", typeof admin);
console.log("Is admin truthy:", !!admin);
console.log("Type of admin.firestore:", typeof admin.firestore);
console.log("Is admin.firestore truthy:", !!admin.firestore);
console.log("--- Debug-Logs Ende ---");
// >>> DEBUG-LOGS ENDE <<<


// Hol dir eine Firestore Instanz und aktiviere ignoreUndefinedProperties
const db = admin.firestore({
  ignoreUndefinedProperties: true // <-- Diese Option hinzugefügt
});

// >>> DEBUG-LOGS START - Nach db Initialisierung <<<
console.log("--- Debug nach db Initialisierung ---");
console.log("Type of db:", typeof db);
console.log("Is db truthy:", !!db);
// Prüfen, ob db.FieldValue existiert (bleibt drin für Info, auch wenn wir es hier nicht nutzen)
console.log("Type of db.FieldValue:", typeof db.FieldValue);
console.log("Is db.FieldValue truthy:", !!db.FieldValue);
console.log("--- Debug-Logs Ende ---");
// >>> DEBUG-LOGS ENDE <<<


// >>> Referenziere FieldValue (Definition bleibt bestehen, wird aber im dataToStore Objekt nicht verwendet) <<<
// Hole FieldValue hier direkt vom firestore Objekt im Admin SDK Namespace
// Dies ist der standardmäßige und empfohlene Weg für statische Eigenschaften
const FieldValue = admin.firestore.FieldValue;
// <<< Ende Referenzierung <<<


// >>> DEBUG-LOGS START - Nach FieldValue Definition <<<
console.log("--- Debug nach FieldValue Definition ---");
console.log("Type of admin.firestore:", typeof admin.firestore);
console.log("Is admin.firestore truthy:", !!admin.firestore);
console.log("Type of admin.firestore.FieldValue:", typeof admin.firestore.FieldValue);
console.log("Is admin.firestore.FieldValue truthy:", !!admin.firestore.FieldValue);
console.log("Type of FieldValue (global const) after definition:", typeof FieldValue);
console.log("Is FieldValue (global const) truthy:", !!FieldValue);
console.log("--- Debug-Logs Ende ---");
// >>> DEBUG-LOGS ENDE <<<


// Deine WordPress API Basis-URLs (übernommen aus deinem WordPressService.dart)
const WP_POSTS_API_URL = 'https://uccelli-society.ch/wp-json/wp/v2/posts';
const TRIBE_EVENTS_API_URL = 'https://uccelli-society.ch/wp-json/tribe/events/v1/events';

// >>> Firestore Sammlung Namen <<<
const POSTS_COLLECTION = 'wordpress_posts';
const EVENTS_COLLECTION = 'tribe_events';
// >>> Ende Sammlung Namen <<<


// Funktion zum Abrufen von Posts von WordPress
async function fetchWordPressPosts() {
    try {
       // Nutze _embed für zusätzliche Details, hole bis zu 100 Posts
         const response = await axios.get(`${WP_POSTS_API_URL}?_embed&per_page=100`);
         if (response.status === 200) {
            return response.data; // Dies ist ein Array von Post-Objekten
            } else {
               console.error('Fehler beim Abrufen von WordPress Posts:', response.status);
               return []; // Leeres Array bei Fehler
               }
            } catch (error) {
               console.error('Fehler bei der HTTP-Anfrage für WordPress Posts:', error);
               return []; // Leeres Array bei Fehler
               }
            }

// Funktion zum Abrufen von Events von WordPress The Events Calendar
async function fetchWordPressEvents() {
  try {
    const response = await axios.get(TRIBE_EVENTS_API_URL); // Nimmt an, dass dies eine Liste von Events zurückgibt
     if (response.status === 200) {
      const data = response.data;
      // Überprüfe, ob die Antwort ein 'events' Array enthält (basierend auf deinem fetchEvents Code)
      if (data && data.events && Array.isArray(data.events)) {
        return data.events; // Dies ist ein Array von Event-Objekten
      } else {
        console.warn('Events API hat kein \'events\' Array zurückgegeben oder die Datenstruktur ist unerwartet.');
        return []; // Leeres Array, wenn 'events' fehlt oder kein Array ist
      }
    } else {
      console.error('Fehler beim Abrufen von WordPress Events:', response.status);
      return []; // Leeres Array bei Fehler
    }
  } catch (error) {
    console.error('Fehler bei der HTTP-Anfrage für WordPress Events:', error);
    return []; // Leeres Array bei Fehler
  }
}

// Funktion zum Synchronisieren von Daten (Posts oder Events) nach Firestore
// data: Array von Objekten (Posts oder Events)
// collectionName: Name der Firestore-Sammlung (z.B. 'wordpress_posts', 'tribe_events')
// idField: Name des Feldes, das als Dokument-ID in Firestore verwendet werden soll (z.B. 'id')
async function syncDataToFirestore(data, collectionName, idField) {
  const batch = db.batch(); // Batch-Schreibvorgänge für Effizienz
  let writeCount = 0; // Zähler für die Anzahl der Schreibvorgänge

  for (const item of data) {
    // Hole die Dokument-ID (WordPress ID oder Event ID) als String
    const docId = item[idField]?.toString();

    // Überspringe Elemente ohne gültige ID
    if (!docId) {
        console.warn(`Element ohne gültige ID im Feld '${idField}' in Sammlung '${collectionName}' gefunden. Element übersprungen:`, item);
        continue;
    }

    const docRef = db.collection(collectionName).doc(docId);

    // >>> DEBUG-LOGS START - Vor dataToStore <<<
    console.log("--- Debug syncDataToFirestore vor dataToStore ---");
    console.log(`Bearbeite Element mit ID: ${docId} in Sammlung: ${collectionName}`);
    console.log("Type of admin:", typeof admin);
    console.log("Is admin truthy:", !!admin);
    console.log("Type of admin.firestore:", typeof admin.firestore);
    console.log("Is admin.firestore truthy:", !!admin.firestore);
    if (db) { // Prüfe db, da FieldValue von db geholt werden sollte (auch wenn es nicht funktioniert)
       console.log("Type of db:", typeof db);
       console.log("Is db truthy:", !!db);
       console.log("Type of db.FieldValue:", typeof db.FieldValue); // <-- Loggt db.FieldValue
       console.log("Is db.FieldValue truthy:", !!db.FieldValue); // <-- Loggt db.FieldValue
    } else {
        console.log("db (Firestore instance) is undefined!");
    }
    console.log("Type of FieldValue (global const):", typeof FieldValue); // <-- Loggt die globale Variable
    console.log("Is FieldValue (global const) truthy:", !!FieldValue); // <-- Loggt die globale Variable
    console.log("--- Debug-Logs Ende - Vor dataToStore ---");
    // >>> DEBUG-LOGS ENDE <<<

    // --- Datenbereinigung: Wähle nur benötigte Felder aus ---
    let cleanedData = {};
    if (collectionName === POSTS_COLLECTION) {
        // Felder für WordPress Posts
        cleanedData = {
            id: item.id,
            date: item.date,
            modified: item.modified,
            slug: item.slug,
            status: item.status,
            type: item.type,
            link: item.link,
            title: item.title ? item.title.rendered : null, // Titel kann verschachtelt sein
            content: item.content ? item.content.rendered : null, // Inhalt kann verschachtelt sein
            excerpt: item.excerpt ? item.excerpt.rendered : null, // Auszug kann verschachtelt sein
            author: item.author, // Typischerweise eine ID
            featured_media: item.featured_media, // Typischerweise eine ID
            comment_status: item.comment_status,
            ping_status: item.ping_status,
            sticky: item.sticky,
            template: item.template,
            format: item.format,
            // taxonomy terms (categories, tags) - können Arrays sein, Firestore-kompatibel?
            // Wir kopieren sie direkt, wenn sie existieren. Firestore unterstützt Arrays von Strings/Zahlen.
            categories: Array.isArray(item.categories) ? item.categories : null,
            tags: Array.isArray(item.tags) ? item.tags : null,
            // _embedded Daten können komplex sein, wir nehmen nur das featuredmedia URL, falls vorhanden
            featured_media_url: (item._embedded && item._embedded['wp:featuredmedia'] && item._embedded['wp:featuredmedia'][0] && item._embedded['wp:featuredmedia'][0].source_url) ? item._embedded['wp:featuredmedia'][0].source_url : null,
            // Füge hier weitere benötigte Felder hinzu
        };
    } else if (collectionName === EVENTS_COLLECTION) {
        // Felder für Tribe Events (Annahmen basierend auf typischer Struktur)
        cleanedData = {
            id: item.id,
            title: item.title,
            description: item.description, // Event Beschreibung
            excerpt: item.excerpt, // Event Auszug
            url: item.url, // Event URL
            start_date: item.start_date,
            end_date: item.end_date,
            all_day: item.all_day,
            // Venue Details (können verschachtelt sein) - NUR benötigte Felder extrahieren und undefined durch null ersetzen
            venue: item.venue ? {
                id: item.venue.id ?? null, // Nutze ?? null, falls id undefined ist
                venue: item.venue.venue ?? null, // Name
                address: item.venue.address ?? null,
                city: item.venue.city ?? null,
                country: item.venue.country ?? null,
                zip: item.venue.zip ?? null,
                state: item.venue.state ?? null, // <-- undefined wird durch null ersetzt
                website: item.venue.website ?? null,
                latitude: item.venue.geo_lat ?? null, // Annahme Feldname
                longitude: item.venue.geo_lng ?? null, // Annahme Feldname
            } : null, // Wenn item.venue null oder undefined ist, setze venue auf null
             // Organizer Details (können verschachtelt sein) - NUR benötigte Felder extrahieren und undefined durch null ersetzen
            organizer: item.organizer ? {
                id: item.organizer.id ?? null, // Nutze ?? null, falls id undefined ist
                organizer: item.organizer.organizer ?? null, // Name
                phone: item.organizer.phone ?? null,
                website: item.organizer.website ?? null,
                email: item.organizer.email ?? null,
            } : null, // Wenn item.organizer null oder undefined ist, setze organizer auf null
            // Event Categories (können Arrays sein) - Extrahiere relevante Kat-Felder und ersetze undefined/null durch null
            categories: Array.isArray(item.categories) ? item.categories.map(cat => ({
                id: cat.id ?? null,
                name: cat.name ?? null,
                slug: cat.slug ?? null
            })) : null, // Wenn item.categories kein Array ist, setze auf null
            // Füge hier weitere benötigte Event-Felder hinzu, behandle undefined/null
        };
    } else {
        // Fallback: Speichere das Original-Item, wenn der Collection-Name unbekannt ist (sollte nicht passieren bei diesen Collections)
        console.warn(`Unbekannte Sammlung '${collectionName}'. Speichere rohe Daten.`);
        cleanedData = item; // Fallback zur rohen Speicherung
    }
    // --- Ende Datenbereinigung ---


    // Bereite die Daten vor, die in Firestore gespeichert werden sollen
    const dataToStore = {
      // Speichere die BEREINIGTEN Daten
      original_data: cleanedData,
      // Placeholder für Übersetzungen (wird später von der Übersetzungsfunktion gefüllt)
      translations: {}, // Standardmäßig leer, oder behalte vorhandene beim Update
      // Füge Zeitstempel hinzu, um Aktualisierungen zu verfolgen
      // WordPress und Tribe Events API haben oft ein 'modified' oder 'date' Feld
      // Nutze den Zeitstempel von der Quelle, wenn verfügbar
      last_updated_source: item.modified || item.date || null, // Nutze weiterhin den Zeitstempel aus dem Original-Item
      // last_synced: FieldValue.serverTimestamp() // <-- Diese Zeile bleibt auskommentiert/entfernt
    };

    // >>> DEBUG-LOGS START - Nach dataToStore <<<
    console.log("--- Debug syncDataToFirestore nach dataToStore ---");
    console.log("Data structure being sent to Firestore:", JSON.stringify(dataToStore, null, 2)); // Loggt die bereinigte Struktur
    console.log("Type of FieldValue (global const) AFTER dataToStore:", typeof FieldValue); // Loggen wir trotzdem
    console.log("Is FieldValue (global const) AFTER dataToStore truthy:", !!FieldValue); // Loggen wir trotzdem
    console.log("--- Debug-Logs Ende - Nach dataToStore ---");
    // >>> DEBUG-LOGS ENDE <<<


    // Prüfe, ob das Dokument in Firestore bereits existiert
    const doc = await docRef.get();

    if (doc.exists) {
        const existingData = doc.data();

        // Behalte vorhandene Übersetzungen, wenn das Dokument aktualisiert wird
        if (existingData.translations) {
            dataToStore.translations = existingData.translations;
        }

        // Behalte den Zeitstempel der letzten Übersetzung, wenn er existiert
        if (existingData.last_translated) {
            dataToStore.last_translated = existingData.last_translated;
        }

        // Optional: Prüfe, ob sich der Inhalt in der Quelle seit der letzten Synchronisierung geändert hat
        // Dies ist eine rudimentäre Prüfung basierend auf last_updated_source
        // Eine tiefere Prüfung könnte die Felder in original_data vergleichen (komplexer)
        const existingLastUpdatedSource = existingData.last_updated_source;
        if (existingLastUpdatedSource && dataToStore.last_updated_source && existingLastUpdatedSource === dataToStore.last_updated_source) {
             console.log(`Element ${docId} in ${collectionName} wurde seit der letzten Synchronisierung in der Quelle nicht aktualisiert. Firestore Update übersprungen.`);
             continue; // Überspringe das Update, wenn sich die Quelle nicht geändert hat
        }

        // Füge den Schreibvorgang zum Batch hinzu (aktualisiere das Dokument)
        // merge: true stellt sicher, dass nur die bereitgestellten Felder aktualisiert werden und andere Felder (wie translations) erhalten bleiben
        batch.set(docRef, dataToStore, { merge: true });
        console.log(`Element ${docId} in ${collectionName} zum Batch für Aktualisierung hinzugefügt.`);
        writeCount++;


    } else {
      // Füge den Schreibvorgang zum Batch hinzu (erstelle ein neues Dokument)
      batch.set(docRef, dataToStore);
      console.log(`Element ${docId} in ${collectionName} zum Batch für Erstellung hinzugefügt.`);
      writeCount++;
    }
  }

  // Führe den Batch aus, wenn Schreibvorgänge vorhanden sind
  if (writeCount > 0) {
      await batch.commit();
      console.log(`Batch für ${collectionName} ausgeführt. ${writeCount} Schreibvorgänge.`);
  } else {
      console.log(`Keine Schreibvorgänge für ${collectionName} erforderlich.`);
  }
}


// HTTP getriggerte Funktion zur Synchronisierung von WordPress-Daten
// TEMPORÄR FÜR LOKALE TESTS
// Kann manuell über eine HTTP-Anfrage ausgelöst werden, wenn die Emulatoren laufen.
exports.syncWordPressDataHttp = functions.https.onRequest(async (request, response) => {
    console.log('HTTP getriggerte WordPress-Synchronisierungsfunktion gestartet.');

    // Rufe Posts ab und synchronisiere sie nach Firestore
    console.log('Rufe WordPress Posts ab...');
    const posts = await fetchWordPressPosts();
    console.log(`Abgerufene Posts: ${posts.length}`);
    await syncDataToFirestore(posts, POSTS_COLLECTION, 'id'); // 'id' ist das Feld, das wir als Dokument-ID verwenden

    // Rufe Events ab und synchronisiere sie nach Firestore
    console.log('Rufe WordPress Events ab...');
    const events = await fetchWordPressEvents();
    console.log(`Abgerufene Events: ${events.length}`);
    // Nehmen wir an, dass auch Events ein 'id' Feld haben
    await syncDataToFirestore(events, EVENTS_COLLECTION, 'id'); // 'id' ist das Feld, das wir als Dokument-ID verwenden

    console.log('HTTP getriggerte WordPress-Synchronisierungsfunktion beendet.');
    response.send("WordPress data sync complete!"); // Sende eine Antwort zurück
});
