// Dieses Script synchronisiert Daten von WordPress/Tribe nach Supabase PostgreSQL
// und ruft dann direkt die Übersetzungs-Edge-Function auf.

const { createClient } = require('@supabase/supabase-js');
const axios = require('axios');

// === Supabase Konfiguration ===
const SUPABASE_URL = 'https://sgauimtpyxqikwuppahe.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNnYXVpbXRweXhxaWt3dXBwYWhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkwMjA4NzksImV4cCI6MjA2NDU5Njg3OX0.6kGegXvsNNJalkCU7p2VgLsd-3cMd_clFMkaFlE3wwM';

// === Edge Function Konfiguration ===
const TRANSLATE_FUNCTION_URL = 'https://sgauimtpyxqikwuppahe.supabase.co/functions/v1/translate-content';
const SUPABASE_SERVICE_ROLE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNnYXVpbXRweXhxaWt3dXBwYWhlIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0OTAyMDg3OSwiZXhwIjoyMDY0NTk2ODc5fQ.EzaRycbwr8ILApRmlwQ28Mylr4hSYstQGBUJhO15vH0'; // Dein Service Role Key

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const WP_POSTS_API_URL = 'https://uccelli-society.ch/wp-json/wp/v2/posts';
const TRIBE_EVENTS_API_URL = 'https://uccelli-society.ch/wp-json/tribe/events/v1/events';

const POSTS_TABLE = 'posts';
const EVENTS_TABLE = 'events';


// Funktion zum Abrufen von Posts von WordPress
async function fetchWordPressPosts() {
    try {
        const response = await axios.get(`${WP_POSTS_API_URL}?_embed&per_page=100`);
        if (response.status === 200) {
            return response.data;
        } else {
            console.error('Fehler beim Abrufen von WordPress Posts:', response.status);
            return [];
        }
    } catch (error) {
        console.error('Fehler bei der HTTP-Anfrage für WordPress Posts:', error);
        return [];
    }
}

// Funktion zum Abrufen von Events von WordPress The Events Calendar
async function fetchWordPressEvents() {
    try {
        const response = await axios.get(TRIBE_EVENTS_API_URL);
        if (response.status === 200) {
            const data = response.data;
            if (data && data.events && Array.isArray(data.events)) {
                return data.events;
            } else {
                console.warn('Events API hat kein \'events\' Array zurückgegeben oder die Datenstruktur ist unerwartet.');
                return [];
            }
        } else {
            console.error('Fehler beim Abrufen von WordPress Events:', response.status);
            return [];
        }
    } catch (error) {
        console.error('Fehler bei der HTTP-Anfrage für WordPress Events:', error);
        return [];
    }
}

// Funktion zum Synchronisieren von Daten nach Supabase und Aufruf der Übersetzungsfunktion
async function syncDataItemToSupabase(dataItem, tableName, idField) {
    const docId = dataItem[idField]?.toString();

    if (!docId) {
        console.warn(`Element ohne gültige ID im Feld '${idField}' in Tabelle '${tableName}' gefunden. Element übersprungen:`, dataItem);
        return;
    }

    let dataToStore = {};

    if (tableName === POSTS_TABLE) {
        dataToStore = {
            id: dataItem.id,
            date: dataItem.date,
            modified: dataItem.modified,
            slug: dataItem.slug,
            status: dataItem.status,
            type: dataItem.type,
            link: dataItem.link,
            title: dataItem.title ? dataItem.title.rendered : null,
            content: dataItem.content ? dataItem.content.rendered : null,
            excerpt: dataItem.excerpt ? dataItem.excerpt.rendered : null,
            author: dataItem.author,
            featured_media: dataItem.featured_media,
            comment_status: dataItem.comment_status,
            ping_status: dataItem.ping_status,
            sticky: dataItem.sticky,
            template: dataItem.template,
            format: dataItem.format,
            categories: Array.isArray(dataItem.categories) ? dataItem.categories : null,
            tags: Array.isArray(dataItem.tags) ? dataItem.tags : null,
            featured_media_url: (dataItem._embedded && dataItem._embedded['wp:featuredmedia'] && dataItem._embedded['wp:featuredmedia'][0] && dataItem._embedded['wp:featuredmedia'][0].source_url) ? dataItem._embedded['wp:featuredmedia'][0].source_url : null,
            last_updated_source: dataItem.modified || dataItem.date || null,
        };
    } else if (tableName === EVENTS_TABLE) {
        dataToStore = {
            id: dataItem.id,
            title: dataItem.title,
            description: dataItem.description,
            excerpt: dataItem.excerpt,
            url: dataItem.url,
            start_date: dataItem.start_date,
            end_date: dataItem.end_date,
            all_day: dataItem.all_day,
            venue: dataItem.venue ?? null,
            organizer: dataItem.organizer ?? null,
            categories: Array.isArray(dataItem.categories) ? dataItem.categories : null,
            last_updated_source: dataItem.modified || dataItem.date || null,
        };
    } else {
        console.warn(`Unbekannte Tabelle '${tableName}'. Überspringe Synchronisierung.`);
        return;
    }

    // 1. Daten in Supabase speichern/aktualisieren (Upsert)
    const { data: upsertData, error: upsertError } = await supabase
        .from(tableName)
        .upsert(dataToStore, { onConflict: 'id' })
        .select(); // '.select()' ist wichtig, um den aktualisierten Datensatz zurückzubekommen

    if (upsertError) {
        console.error(`Fehler beim Synchronisieren von Dokument ${docId} in Tabelle ${tableName}:`, upsertError);
        return; // Beende, wenn Upsert fehlschlägt
    } else {
        console.log(`Dokument ${docId} in Tabelle ${tableName} erfolgreich synchronisiert.`);
    }

    // 2. Übersetzungs-Edge-Function direkt aufrufen
    // Wir senden den 'record' (den soeben aktualisierten Datensatz) und 'table' an die Funktion.
    // Der 'event' ist hier immer 'UPDATE' für das Script-Szenario.
    try {
        const functionPayload = {
            record: upsertData[0], // Nimm den ersten (und einzigen) Datensatz vom Upsert-Ergebnis
            old_record: null, // Für dieses Script-Szenario können wir old_record als null setzen
            event: 'UPDATE', // Simuliere ein UPDATE-Event
            table: tableName,
            schema: 'public'
        };

        const response = await axios.post(TRANSLATE_FUNCTION_URL, functionPayload, {
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`
            }
        });

        if (response.status === 200) {
            console.log(`Übersetzungs-Edge-Function für ${tableName} ID ${docId} erfolgreich aufgerufen.`);
            console.log('Edge Function Response:', response.data);
        } else {
            console.error(`Fehler beim Aufruf der Übersetzungs-Edge-Function für ${tableName} ID ${docId}: Status ${response.status}, Antwort: ${JSON.stringify(response.data)}`);
        }
    } catch (error) {
        console.error(`Ausnahme beim Aufruf der Übersetzungs-Edge-Function für ${tableName} ID ${docId}:`, error.message || error);
    }
}


// Hauptfunktion des Scripts
async function main() {
  console.log('Node.js Sync Script für Supabase gestartet.');

  // Rufe Posts ab und synchronisiere sie nach Supabase
  console.log('Rufe WordPress Posts ab...');
  const posts = await fetchWordPressPosts();
  console.log(`Abgerufene Posts: ${posts.length}`);
  for (const post of posts) {
      await syncDataItemToSupabase(post, POSTS_TABLE, 'id');
  }

  // Rufe Events ab und synchronisiere sie nach Supabase
  console.log('Rufe WordPress Events ab...');
  const events = await fetchWordPressEvents();
  console.log(`Abgerufene Events: ${events.length}`);
   for (const event of events) {
      await syncDataItemToSupabase(event, EVENTS_TABLE, 'id');
  }

  console.log('Node.js Sync Script für Supabase beendet.');
}

// Script ausführen
main().catch(console.error);
