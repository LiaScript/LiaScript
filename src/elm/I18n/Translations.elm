module I18n.Translations exposing (..)

{-| This file was automatically generated with elm-i18n-gen --compact.
For more in information visit:

<https://github.com/andre-dietrich/elm-i18n-module-generator>

-}

import Array exposing (Array)


{-| A language, its code and its texts, see `getLnFromCode`.
-}
type Lang
    = Lang String (Array String)


{-| The default language, its texts are part of the functions.
-}
en : Lang
en =
    Lang "en" Array.empty


{-| Pass a language code that will return a Lang-type, if it exists.
Otherwise `Nothing` is returned. The texts of the language are split from
one string, so call it once and keep the result.
-}
getLnFromCode : String -> Maybe Lang
getLnFromCode code =
    let
        lower =
            String.toLower code

        load texts =
            Just (Lang lower (Array.fromList (String.split "|" texts)))
    in
    case lower of
        "ca" ->
            load "Aa|Tanca el diàleg|esborra la cerca|Estil de l'editor|mida de la lletra: ~|Nota al peu|Notes al peu|Català|s'obre en una pestanya nova|següent|cap resultat|un resultat|reprodueix|anterior|Redimensiona els panells|resultats|Cerca|petita|mitjana|gran|Salta la navegació|Diapositiva|Navegació per les diapositives|Pas|atura|Taula de continguts|Amplia|Blau|Mode clar|Mode fosc|Per defecte|Vermell|Esquema de colors|Turquesa|Groc|Gràfic de barres|Diagrama de caixa|Gràfic|Gràfic d'embut|Graf de relacions|Mapa de calor|Gràfic de línies|Mapa|Gràfic de coordenades paral·leles|Gràfic de sectors|Gràfic de radar|Diagrama de Sankey|Diagrama de dispersió|Taula|Núvol de paraules|Tanca el xat|Missatge de xat|Tens missatges de xat sense llegir|Obre el xat|Envia un missatge|Remitent no verificat|Bloc de codi|copiat al porta-retalls|copia al porta-retalls|Editor de codi|Executa|primera versió|última versió|maximitza la vista|minimitza la vista|versió següent|versió anterior|restableix l'entrada|s'està executant|Envia al terminal|terminal|Amaga els comentaris de vídeo i d'avatar|Ajusta el to de la veu|To|Ajusta la velocitat de reproducció|Velocitat|Comentaris|No dependre només del color|Obre l'editor|Informació|Configuració|Comparteix|comparteix mitjançant ...|Profunditat de l'índex|Indicadors de funció|Traduccions|Entra a pantalla completa|Surt de pantalla completa|Inici|Autor: |Autors: |Data: |Correu electrònic: |Baixa els mitjans per a ús sense connexió|fallits|Mitjans sense connexió|Versió: |Mode de presentació|Amaga la navegació|Presentació|Diapositives|Llibre de text|Codi QR del lloc web|Amplia el codi QR|Error en generar el codi QR|Encara no s'ha donat la resposta correcta|Resposta revelada|Enhorabona, aquesta era la resposta correcta|Comprova|Prem Retorn en una zona per seleccionar-la i després Retorn en una targeta per col·locar-la-hi|Zona per deixar anar|buida|Buit|mostra una pista|Resposta|Comprova la resposta. La resposta es marcarà com a correcta o incorrecta.|Mostra la solució. L'exercici es marcarà com a resolt.|selecció|mostra la solució|ordena de manera ascendent|ordena de manera descendent|sense ordenar|So desactivat|So activat|Cal respondre la pregunta abans de l'enviament.|Cal respondre totes les files abans de l'enviament.|Envia|Gràcies pels teus comentaris!|Introdueix un text...|Actualitza|Tradueix amb Google (experimental)|de|Pausa|Posició de reproducció|Prefereix la síntesi de veu del navegador|Reprèn|El teu navegador no admet la síntesi de veu. Prova'n un altre.|S'utilitza el motor de síntesi de veu integrat del navegador."

        "de" ->
            load "Aa|Dialog schließen|Suche löschen|Editor-Stil|Schriftgröße: ~|Fußnote|Fußnoten|Deutsch|öffnet in neuem Tab|weiter|kein Ergebnis|ein Ergebnis|Wiedergabe|zurück|Größe der Bereiche ändern|Ergebnisse|Suche|klein|mittel|groß|Navigation überspringen|Folie|Folien-Navigation|Schritt|Stopp|Inhaltsverzeichnis|Vergrößern|Blau|Hellmodus|Dunkelmodus|Standard|Rot|Farbschema|Türkis|Gelb|Balkendiagramm|Boxplot|Diagramm|Trichterdiagramm|Beziehungsgrafik|Heatmap|Liniendiagramm|Karte|Parallele Koordinatenkarte|Tortendiagramm|Radar-Karte|Sankey-Diagramm|Streudiagramm|Tabelle|Wortwolke|Chat schließen|Chat-Nachricht|Du hast ungelesene Chat-Nachrichten|Chat öffnen|Nachricht senden|Unbestätigter Absender|Codeblock|in die Zwischenablage kopiert|in die Zwischenablage kopieren|Code-Editor|Ausführen|erste Version|letzte Version|Darstellung maximieren|Darstellung minimieren|eine Version vor|eine Version zurück|Eingabe zurücksetzen|wird ausgeführt|An das Terminal senden|Terminal|Video- & Avatar-Kommentare ausblenden|Anpassung der Tonhöhe|Tonhöhe|Anpassung der Abspielgeschwindigkeit|Tempo|Kommentare|Nicht nur Farben verwenden|Editor öffnen|Informationen|Einstellungen|Teilen|Teilen per ...|Tiefe des Inhaltsverzeichnisses|Tooltipps|Übersetzungen|Vollbildmodus aktivieren|Vollbildmodus beenden|Übersicht|Autor: |Autoren: |Datum: |E-Mail: |Medien für offline herunterladen|fehlgeschlagen|Medien offline|Version: |Präsentationsmodus|Navigation ausblenden|Präsentation|Folien|Lehrbuch|QR-Code für Webseite|QR-Code vergrößern|Fehler beim Codieren in QR-Code|Die richtige Antwort wurde noch nicht gegeben|Aufgelöste Antwort|Herzlichen Glückwunsch, das war die richtige Antwort|Prüfen|Mit Enter ein Ablagefeld wählen, dann mit Enter eine Karte darauf ablegen|Ablagefeld|leer|Lücke|Hinweis anzeigen|Antwort|Überprüfe die Antwort. Die Antwort wird als richtig oder falsch markiert.|Zeige die Lösung. Das Quiz wird als aufgelöst markiert.|Auswahl|zeige Lösung|aufsteigend sortieren|absteigend sortieren|nicht sortiert|Sprecher aus|Sprecher an|Die Frage muss vor dem Absenden beantwortet werden.|Vor dem Absenden muss jede Zeile beantwortet werden.|Abschicken|Vielen Dank für dein Feedback!|Texteingabe ...|Aktualisieren|Mit Google übersetzen (experimentell)|von|Pausieren|Wiedergabeposition|Browser-TTS bevorzugen|Fortsetzen|Ihr Browser unterstützt kein Text-to-Speech, versuchen Sie es mit einem anderen.|Verwendung der internen Text-zu-Speech-Engine des Browsers."

        "es" ->
            load "Aa|Cerrar diálogo|eliminar búsqueda|estilo editor|Tamaño de fuente: ~|Nota al pie|Notas al pie|Español|se abre en una pestaña nueva|siguiente|No hay resultados|un resultado|reproducir|anterior|Cambiar el tamaño de los paneles|Resultados|buscar|pequeño|mediano|grande|Saltar navegación|Diapositiva|Navegación de diapositivas|Paso|parar|índice|Ampliar|azul|modo claro|modo oscuro|predeterminado|rojo|Esquema de colores|turquesa|amarillo|Gráfico de barras|Diagrama de caja|Gráfico|Gráfico de embudo|Grafo de relaciones|Mapa de calor|Gráfico de líneas|Mapa|Gráfico de coordenadas paralelas|Gráfico circular|Gráfico de radar|Diagrama de Sankey|Diagrama de dispersión|Tabla|Nube de palabras|Cerrar chat|Mensaje de chat|Tienes mensajes de chat no leídos|Abrir chat|Enviar mensaje|Remitente no verificado|Bloque de código|copiado al portapapeles|copiar al portapapeles|Editor de código|ejecutar|primera versión|última versión|maximizar vista|minimizar vista|versión siguiente|versión anterior|restablecer entrada|en funcionamiento|Enviar al terminal|terminal|Ocultar los comentarios de video y avatar|ajustar tono|Tono|ajustar velocidad de reproducción|Velocidad|Comentarios|No depender solo del color|Abrir editor|información|configuración|compartir|compartir vía ...|Profundidad del índice|Descripciones emergentes|traducciones|entrar en pantalla completa|salir de pantalla completa|Inicio|Autor: |Autores: |Fecha: |Correo electrónico: |Descargar multimedia para usar sin conexión|fallidos|Multimedia sin conexión|Versión: |Modo presentación|Ocultar navegación|Presentación|Diapositivas|Manual|Código QR para sitio web|Ampliar código QR|Error al codificar en código QR|La respuesta correcta aún no ha sido dada|Respuesta resuelta|Felicitaciones, esa fue la respuesta correcta|verificar|Pulsa Enter en una zona de destino para seleccionarla y luego Enter en una tarjeta para colocarla allí|Zona de destino|vacía|Hueco|mostrar pista|Respuesta|Comprueba la respuesta. Se marcará como correcta o incorrecta.|Muestra la solución. El cuestionario se marcará como resuelto.|selección|mostrar solución|orden ascendente|orden descendente|no ordenado|Sonido apagado|Sonido encendido|La pregunta debe responderse antes del envío.|Todas las filas deben responderse antes del envío.|enviar|¡Gracias por tus comentarios!|introducir texto|Actualizar|Traducir con Google (experimental)|de|Pausar|Posición de reproducción|Preferir TTS del navegador|Reanudar|Tu navegador no es compatible con la conversión de texto a voz, prueba con otro.|Usando el motor interno de conversión de texto a voz del navegador."

        "eu" ->
            load "Aa|Itxi elkarrizketa-koadroa|garbitu bilaketa|Editorearen estiloa|letra-tamaina: ~|Oin-oharra|Oin-oharrak|Euskara|fitxa berri batean irekitzen da|hurrengoa|emaitzarik ez|emaitza bat|erreproduzitu|aurrekoa|Aldatu panelen tamaina|emaitzak|Bilatu|txikia|ertaina|handia|Saltatu nabigazioa|Diapositiba|Diapositiben nabigazioa|Urratsa|gelditu|Aurkibidea|Handitu|Urdina|Modu argia|Modu iluna|Lehenetsia|Gorria|Kolore-eskema|Turkesa|Horia|Barra-diagrama|Kutxa-diagrama|Diagrama|Inbutu-diagrama|Erlazio-grafoa|Bero-mapa|Lerro-diagrama|Mapa|Koordenatu paraleloen diagrama|Sektore-diagrama|Radar-diagrama|Sankey diagrama|Sakabanatze-diagrama|Taula|Hitz-hodeia|Itxi txata|Txat-mezua|Irakurri gabeko txat-mezuak dituzu|Ireki txata|Bidali mezua|Egiaztatu gabeko igorlea|Kode-blokea|arbelean kopiatuta|kopiatu arbelean|Kode-editorea|Exekutatu|lehen bertsioa|azken bertsioa|maximizatu ikuspegia|minimizatu ikuspegia|hurrengo bertsioa|aurreko bertsioa|berrezarri sarrera|exekutatzen ari da|Bidali terminalera|terminala|Ezkutatu bideo- eta avatar-iruzkinak|Doitu ahotsaren tonua|Tonua|Doitu erreprodukzio-abiadura|Abiadura|Iruzkinak|Ez erabili koloreak soilik|Ireki editorea|Informazioa|Ezarpenak|Partekatu|partekatu ... bidez|Aurkibidearen sakonera|Tresna-aholkuak|Itzulpenak|Sartu pantaila osoko moduan|Irten pantaila osoko modutik|Hasiera|Egilea: |Egileak: |Data: |Posta elektronikoa: |Deskargatu multimedia lineaz kanpo erabiltzeko|huts egin du|Multimedia lineaz kanpo|Bertsioa: |Aurkezpen-modua|Ezkutatu nabigazioa|Aurkezpena|Diapositibak|Testuliburua|Webgunearen QR kodea|Handitu QR kodea|Errorea QR kodea sortzean|Oraindik ez da erantzun zuzena eman|Agerian jarritako erantzuna|Zorionak, hori zen erantzun zuzena|Egiaztatu|Sakatu Enter jaregite-eremu batean hura hautatzeko, eta gero Enter txartel batean bertan kokatzeko|Jaregite-eremua|hutsik|Hutsunea|erakutsi pista|Erantzuna|Egiaztatu erantzuna. Erantzuna zuzen edo oker gisa markatuko da.|Erakutsi ebazpena. Ariketa ebatzita dagoela markatuko da.|hautaketa|erakutsi ebazpena|ordenatu gorantz|ordenatu beherantz|ordenatu gabe|Desaktibatu soinua|Aktibatu soinua|Galderari erantzun behar zaio bidali aurretik.|Errenkada guztiei erantzun behar zaie bidali aurretik.|Bidali|Eskerrik asko zure iritziagatik!|Idatzi testua...|Eguneratu|Itzuli Google-rekin (esperimentala)|/|Pausatu|Erreprodukzio-posizioa|Lehenetsi nabigatzailearen hizketa-sintesia|Jarraitu|Zure nabigatzaileak ez du hizketa-sintesia onartzen. Probatu beste bat.|Nabigatzailearen hizketa-sintesi integratua erabiltzen ari da."

        "ga" ->
            load "Aa|Dún an bosca dialóige|glan an cuardach|Stíl an eagarthóra|clómhéid: ~|Fonóta|Fonótaí|Gaeilge|osclaítear i gcluaisín nua é|ar aghaidh|gan torthaí|toradh amháin|seinn|siar|Athraigh méid na bpainéal|torthaí|Cuardaigh|beag|meánach|mór|Léim thar an nascleanúint|Sleamhnán|Nascleanúint sleamhnán|Céim|stop|Clár na nÁbhar|Méadaigh|Gorm|Mód geal|Mód dorcha|Réamhshocrú|Dearg|Scéim dathanna|Turcaid|Buí|Barrachairt|Boscaplot|Cairt|Cairt tonnadóra|Graf gaolmhaireachtaí|Léarscáil teasa|Línechairt|Léarscáil|Cairt comhordanáidí comhthreomhara|Píchairt|Cairt radair|Léaráid Sankey|Scaipghraf|Tábla|Scamall focal|Dún an comhrá|Teachtaireacht chomhrá|Tá teachtaireachtaí comhrá neamhléite agat|Oscail an comhrá|Seol teachtaireacht|Seoltóir neamhfhíoraithe|Bloc cóid|cóipeáilte chuig an ngearrthaisce|cóipeáil chuig an ngearrthaisce|Eagarthóir cóid|Rith|an chéad leagan|an leagan deireanach|uasmhéadaigh an t-amharc|íoslaghdaigh an t-amharc|an chéad leagan eile|an leagan roimhe|athshocraigh an t-ionchur|ag rith|Seol chuig an teirminéal|teirminéal|Folaigh nótaí tráchta físe agus abhatáir|Coigeartaigh tuinairde an ghutha|Tuinairde|Coigeartaigh luas na hathsheinnte|Luas|Nótaí tráchta|Ná bí ag brath ar dhath amháin|Oscail an t-eagarthóir|Eolas|Socruithe|Comhroinn|comhroinn trí ...|Doimhneacht an chláir ábhair|Leideanna uirlisí|Aistriúcháin|Téigh go lánscáileán|Scoir den lánscáileán|Baile|Údar: |Údair: |Dáta: |Ríomhphost: |Íoslódáil meáin le húsáid as líne|theip|Meáin as líne|Leagan: |Mód cur i láthair|Folaigh an nascleanúint|Cur i láthair|Sleamhnáin|Téacsleabhar|Cód QR don suíomh gréasáin|Méadaigh an cód QR|Earráid agus cód QR á chruthú|Níor tugadh an freagra ceart fós|Freagra nochta|Comhghairdeas, ba é sin an freagra ceart|Seiceáil|Brúigh Enter ar limistéar scaoilte chun é a roghnú, ansin Enter ar chárta chun é a chur ann|Limistéar scaoilte|folamh|Bearna|taispeáin leid|Freagra|Seiceáil an freagra. Marcálfar an freagra mar cheart nó mícheart.|Taispeáin an réiteach. Marcálfar an cleachtadh mar réitithe.|roghnú|taispeáin an réiteach|sórtáil in ord ardaitheach|sórtáil in ord íslitheach|gan sórtáil|Fuaim múchta|Fuaim ar siúl|Caithfear an cheist a fhreagairt roimh sheoladh.|Caithfear gach ró a fhreagairt roimh sheoladh.|Seol|Go raibh maith agat as d'aiseolas!|Cuir téacs isteach...|Nuashonraigh|Aistrigh le Google (turgnamhach)|as|Sos|Suíomh athsheinnte|Tabhair tús áite do shintéis cainte an bhrabhsálaí|Atosaigh|Ní thacaíonn do bhrabhsálaí le sintéis cainte. Bain triail as brabhsálaí eile.|Tá sintéis cainte ionsuite an bhrabhsálaí in úsáid."

        "it" ->
            load "Aa|Chiudi la finestra di dialogo|cancella ricerca|stile editor|Dimensione carattere: ~|Nota|Note|Italiano|si apre in una nuova scheda|prossimo|non ci sono risultati|un risultato|avvia|precedente|Ridimensiona i riquadri|risultati|Cerca|piccolo|medio|grande|Salta la navigazione|Diapositiva|Navigazione diapositive|Passo|ferma|indice|Ingrandisci|blu|modalità chiara|modalità scura|predefinito|rosso|Schema di colori|turchese|giallo|Diagramma a barre|Diagramma a scatola|Grafico|Grafico a imbuto|Grafico delle relazioni|Mappa termica|Diagramma a linee|Mappa|Mappa a coordinate parallele|Diagramma a torta|Diagramma Radar|Diagramma di Sankey|Diagramma a dispersione|Tabella|Nuvola di parole|Chiudere la chat|Messaggio della chat|Ci sono messaggi di chat non letti|Aprire la chat|Invia messaggio|Mittente non verificato|Blocco di codice|copiato negli appunti|copia negli appunti|Editor di codice|Esegui|prima versione|ultima versione|massimizzare la vista|minimizzare la vista|versione seguente|versione precedente|ripristina l'input|in esecuzione|Invia al terminale|terminale|Nascondi i commenti video e avatar|Regola l'altezza del tono|Tono|Regola la velocità di riproduzione|Velocità|Commenti|Non affidarti solo ai colori|Apri l'editor|Informazioni|Impostazioni|Condividi|Condividi via ...|Profondità dell'indice|Suggerimenti|Traduzioni|Entra a schermo intero|Esci da schermo intero|Home|Autore: |Autori: |Data: |Email: |Scarica i media per l'uso offline|non riusciti|Media offline|Versione: |Modalità presentazione|Nascondi navigazione|Presentazione|Diapositive|Manuale|Codice QR del sito web|Ingrandisci il codice QR|Errore nel codificare come codice QR|La risposta corretta non è stata ancora fornita|Risposta rivelata|Congratulazioni, questa era la risposta corretta|verifica|Premi Invio su un'area di rilascio per selezionarla, poi Invio su una scheda per posizionarla lì|Area di rilascio|vuota|Lacuna|mostra un indizio|Risposta|Controlla la risposta. La risposta è indicata come corretta o errata.|Mostra la soluzione. Il quiz verrà contrassegnato come risolto.|seleziona|mostra la soluzione|ordine crescente|ordine discendente|non ordinato|Suono disattivato|Suono attivo|È necessario rispondere alla domanda prima dell'invio.|È necessario rispondere a ogni riga prima dell'invio.|Invia|Grazie per il tuo feedback!|Immetti del testo|Aggiorna|Tradurre con Google (sperimentale)|di|Pausa|Posizione di riproduzione|Preferisci la sintesi vocale del browser|Riprendi|Il tuo browser non supporta la sintesi vocale, provane un altro.|Viene utilizzata la sintesi vocale integrata del browser."

        "ms" ->
            load "Aa|Tutup dialog|kosongkan carian|Gaya Editor|saiz fon: ~|Nota kaki|Nota kaki|Bahasa Melayu|dibuka dalam tab baharu|seterusnya|tiada hasil|satu hasil|main|sebelumnya|Ubah saiz panel|hasil|Cari|kecil|sederhana|besar|Langkau navigasi|Slaid|Navigasi slaid|Langkah|henti|Isi Kandungan|Besarkan|Biru|Mod Terang|Mod Gelap|Lalai|Merah|Skema warna|Firus|Kuning|Carta bar|Plot kotak|Carta|Carta corong|Graf hubungan|Peta haba|Carta garis|Peta|Peta koordinat selari|Carta pai|Carta radar|Rajah Sankey|Plot serakan|Jadual|Awan perkataan|Tutup sembang|Mesej sembang|Anda mempunyai mesej sembang yang belum dibaca|Buka sembang|Hantar mesej|Penghantar tidak disahkan|Blok kod|disalin ke papan keratan|salin ke papan keratan|Editor kod|Laksana|versi pertama|versi terakhir|besarkan paparan|kecilkan paparan|versi seterusnya|versi sebelumnya|set semula input|sedang berjalan|Hantar ke terminal|terminal|Sembunyikan komen video & avatar|Laraskan nada|Nada|Laraskan kelajuan main balik|Kelajuan|Komen|Jangan bergantung pada warna sahaja|Buka editor|Maklumat|Tetapan|Kongsi|kongsi melalui ...|Kedalaman jadual kandungan|Petua alat|Terjemahan|Masuk Skrin Penuh|Keluar Skrin Penuh|Laman Utama|Pengarang: |Pengarang: |Tarikh: |E-mel: |Muat turun media untuk kegunaan luar talian|gagal|Media luar talian|Versi: |Mod persembahan|Sembunyikan navigasi|Persembahan|Slaid|Buku teks|Kod QR untuk laman web|Besarkan kod QR|Ralat semasa mengekod ke kod QR|Jawapan yang betul belum diberikan|Jawapan diselesaikan|Tahniah, itu jawapan yang betul|Semak|Tekan Enter pada zon lepas untuk memilihnya, kemudian Enter pada kad untuk meletakkannya di situ|Zon lepas|kosong|Ruang kosong|tunjukkan petunjuk|Jawapan|Semak jawapan. Jawapan akan ditandakan sebagai betul atau salah.|Tunjukkan penyelesaian. Kuiz akan ditandakan sebagai selesai.|pilihan|tunjukkan penyelesaian|isih menaik|isih menurun|tidak diisih|Bunyi mati|Bunyi hidup|Soalan ini mesti dijawab sebelum dihantar.|Setiap baris mesti dijawab sebelum dihantar.|Hantar|Terima kasih atas maklum balas anda!|Masukkan teks...|Kemas kini|Terjemah dengan Google (eksperimental)|daripada|Jeda|Kedudukan main balik|Utamakan TTS pelayar|Sambung|Pelayar anda tidak menyokong teks-ke-pertuturan, cuba pelayar lain.|Menggunakan enjin teks-ke-pertuturan dalaman pelayar."

        "pt" ->
            load "Aa|Fechar diálogo|limpar busca|Estilo do editor|tamanho da fonte: ~|Nota de rodapé|Notas de rodapé|Português|abre em uma nova aba|próximo|sem resultados|um resultado|reproduzir|anterior|Redimensionar painéis|resultados|Buscar|pequeno|médio|grande|Pular navegação|Slide|Navegação dos slides|Passo|parar|Sumário|Ampliar|Azul|Modo claro|Modo escuro|Padrão|Vermelho|Esquema de cores|Turquesa|Amarelo|Gráfico de barras|Diagrama de caixa|Gráfico|Gráfico de funil|Gráfico de relacionamento|Mapa de calor|Gráfico de linhas|Mapa|Mapa de coordenadas paralelas|Gráfico de pizza|Gráfico de radar|Diagrama de Sankey|Gráfico de dispersão|Tabela|Nuvem de palavras|Fechar chat|Mensagem de chat|Você tem mensagens de chat não lidas|Abrir chat|Enviar mensagem|Remetente não verificado|Bloco de código|copiado para a área de transferência|copiar para a área de transferência|Editor de código|Executar|primeira versão|última versão|maximizar visualização|minimizar visualização|próxima versão|versão anterior|redefinir entrada|está sendo executado|Enviar ao terminal|terminal|Ocultar comentários de vídeo e avatar|Ajustar tom|Tom|Ajustar velocidade de reprodução|Ritmo|Comentários|Não depender apenas de cores|Abrir editor|Informação|Configurações|Compartilhar|compartilhar via ...|Profundidade do índice|Dicas de ferramentas|Traduções|Entrar em tela cheia|Sair da tela cheia|Início|Autor: |Autores: |Data: |Email: |Baixar mídia para uso offline|falharam|Mídia offline|Versão: |Modo apresentação|Ocultar navegação|Apresentação|Slides|Livro-texto|Código QR para site|Ampliar código QR|Erro durante a codificação para o código QR|A resposta correta ainda não foi dada.|Resposta revelada|Parabéns, essa foi a resposta certa.|Verificar|Pressione Enter em uma área de soltar para selecioná-la e, em seguida, Enter em um cartão para colocá-lo nela|Área de soltar|vazia|Lacuna|mostrar dica|Resposta|Verifique a resposta. A resposta será marcada como correta ou incorreta.|Mostrar a solução. O quiz será marcado como resolvido.|seleção|mostrar solução|ordenar em ordem crescente|ordenar em ordem decrescente|não ordenado|Som desligado|Som ligado|A pergunta deve ser respondida antes do envio.|Todas as linhas devem ser respondidas antes do envio.|Enviar|Obrigado pelo seu feedback!|Digite algum texto...|Atualizar|Traduzir com Google (experimental)|de|Pausar|Posição de reprodução|Preferir TTS do navegador|Retomar|Seu navegador não suporta Texto-para-Fala, tente outro.|Usando o motor interno de Texto-para-Fala do navegador."

        "sw" ->
            load "Aa|Funga kidirisha|futa utafutaji|Mtindo wa Kihariri|ukubwa wa fonti: ~|Tanbihi|Tanbihi|Kiswahili|hufunguka kwenye kichupo kipya|ijayo|hakuna matokeo|tokeo moja|cheza|iliyopita|Badilisha ukubwa wa vidirisha|matokeo|Tafuta|ndogo|ya kati|kubwa|Ruka urambazaji|Slaidi|Urambazaji wa slaidi|Hatua|simamisha|Yaliyomo|Kuza|Bluu|Hali ya Mwanga|Hali ya Giza|Chaguomsingi|Nyekundu|Mpango wa rangi|Feruzi|Njano|Chati ya pau|Boxplot|Chati|Chati ya faneli|Grafu ya uhusiano|Ramani ya joto|Chati ya mstari|Ramani|Chati ya viwianishi sambamba|Chati ya pai|Chati ya rada|Mchoro wa Sankey|Chati ya mtawanyiko|Jedwali|Wingu la maneno|Funga gumzo|Ujumbe wa gumzo|Una ujumbe wa gumzo ambao haujasomwa|Fungua gumzo|Tuma ujumbe|Mtumaji asiyethibitishwa|Kipande cha msimbo|imenakiliwa kwenye ubao wa kunakili|nakili kwenye ubao wa kunakili|Kihariri cha msimbo|Tekeleza|toleo la kwanza|toleo la mwisho|ongeza mtazamo|punguza mtazamo|toleo linalofuata|toleo la awali|weka upya ingizo|inaendeshwa|Tuma kwenye terminal|terminal|Ficha maoni ya video na avatar|Badilisha kiwango cha sauti|Kiwango|Badilisha kasi ya kucheza|Kasi|Maoni|Usitegemee rangi pekee|Fungua Kihariri|Taarifa|Mipangilio|Shiriki|shiriki kupitia ...|Kina cha jedwali la yaliyomo|Vidokezo vya zana|Tafsiri|Ingia kwenye skrini kamili|Toka kwenye skrini kamili|Nyumbani|Mwandishi: |Waandishi: |Tarehe: |Barua pepe: |Pakua media kwa matumizi nje ya mtandao|imeshindwa|Media nje ya mtandao|Toleo: |Hali ya uwasilishaji|Ficha urambazaji|Uwasilishaji|Slaidi|Kitabu cha kiada|Msimbo wa QR wa tovuti|Kuza msimbo wa QR|Hitilafu wakati wa kusimba msimbo wa QR|Jibu sahihi bado halijatolewa|Jibu lililotatuliwa|Hongera, hilo lilikuwa jibu sahihi|Angalia|Bonyeza Enter kwenye eneo la kudondoshea ili kulichagua, kisha Enter kwenye kadi ili kuiweka hapo|Eneo la kudondoshea|tupu|Pengo|onyesha kidokezo|Jibu|Angalia jibu. Jibu litawekwa alama kuwa sahihi au si sahihi.|Onyesha suluhisho. Maswali yatatiwa alama kuwa yametatuliwa.|uteuzi|onyesha suluhisho|panga kwa kupanda|panga kwa kushuka|haijapangwa|Sauti imezimwa|Sauti imewashwa|Swali linapaswa kujibiwa kabla ya kuwasilisha.|Kila safu inapaswa kujibiwa kabla ya kuwasilisha.|Wasilisha|Asante kwa maoni yako!|Weka maandishi...|Sasisha|Tafsiri na Google (majaribio)|kati ya|Sitisha|Nafasi ya uchezaji|Pendelea TTS ya kivinjari|Endelea|Kivinjari chako hakiauni Maandishi-hadi-Hotuba, jaribu kingine.|Inatumia injini ya ndani ya kivinjari ya Maandishi-hadi-Hotuba."

        "sq" ->
            load "Aa|Mbyll dialogun|pastro kërkimin|Stili i redaktuesit|madhësia e shkronjave: ~|Shënim në fund të faqes|Shënimet në fund të faqes|Shqip|hapet në një skedë të re|tjetri|asnjë rezultat|një rezultat|luaj|i mëparshmi|Ndrysho madhësinë e paneleve|rezultate|Kërko|e vogël|mesatare|e madhe|Kapërce navigimin|Diapozitivi|Navigimi i diapozitivave|Hapi|ndalo|Pasqyra e lëndës|Zmadho|Blu|Modaliteti i çelët|Modaliteti i errët|Parazgjedhja|E kuqe|Skema e ngjyrave|Bruz|E verdhë|Diagram me shtylla|Diagram kuti|Diagram|Diagram hinkë|Graf marrëdhëniesh|Hartë nxehtësie|Diagram vijor|Hartë|Diagram me koordinata paralele|Diagram rrethor|Diagram radar|Diagram Sankey|Diagram shpërndarjeje|Tabela|Re fjalësh|Mbyll bisedën|Mesazh bisede|Ke mesazhe të palexuara në bisedë|Hap bisedën|Dërgo mesazh|Dërgues i paverifikuar|Blloku i kodit|u kopjua në kujtesën e përkohshme|kopjo në kujtesën e përkohshme|Redaktuesi i kodit|Ekzekuto|versioni i parë|versioni i fundit|maksimizo pamjen|minimizo pamjen|versioni tjetër|versioni i mëparshëm|rivendos hyrjen|po ekzekutohet|Dërgo në terminal|terminal|Fshih komentet me video dhe avatar|Rregullo lartësinë e zërit|Toni|Rregullo shpejtësinë e riprodhimit|Ritmi|Komentet|Mos u mbështet vetëm te ngjyrat|Hap redaktuesin|Informacion|Cilësimet|Ndaj|ndaj nëpërmjet ...|Thellësia e përmbajtjes|Këshilla për mjetet|Përkthime|Hap ekranin e plotë|Dil nga ekrani i plotë|Kreu|Autori: |Autorët: |Data: |Email: |Shkarko mediat për përdorim jashtë linje|dështuan|Mediat jashtë linje|Versioni: |Modaliteti i prezantimit|Fshih navigimin|Prezantim|Diapozitiva|Libër mësimor|Kodi QR për faqen e internetit|Zmadho kodin QR|Gabim gjatë krijimit të kodit QR|Përgjigjja e saktë nuk është dhënë ende|Përgjigjja e zbuluar|Urime, kjo ishte përgjigjja e saktë|Kontrollo|Shtyp Enter mbi një zonë lëshimi për ta zgjedhur, pastaj Enter mbi një kartë për ta vendosur atje|Zona e lëshimit|bosh|Boshllëku|shfaq ndihmën|Përgjigjja|Kontrollo përgjigjen. Përgjigjja do të shënohet si e saktë ose e pasaktë.|Shfaq zgjidhjen. Ushtrimi do të shënohet si i zgjidhur.|përzgjedhje|shfaq zgjidhjen|rendit në rritje|rendit në zbritje|pa renditje|Zëri i çaktivizuar|Zëri i aktivizuar|Para dërgimit duhet t'i jepet përgjigje pyetjes.|Para dërgimit duhet t'i jepet përgjigje çdo rreshti.|Dërgo|Faleminderit për mendimin tënd!|Shkruaj një tekst...|Përditëso|Përkthe me Google (eksperimentale)|nga|Pauzë|Pozicioni i riprodhimit|Prefero sintezën e të folurit të shfletuesit|Vazhdo|Shfletuesi yt nuk e mbështet sintezën e të folurit. Provo një tjetër.|Po përdoret motori i integruar i sintezës së të folurit të shfletuesit."

        "et" ->
            load "Aa|Sulge dialoog|tühjenda otsing|Redaktori stiil|kirjasuurus: ~|Joonealune märkus|Joonealused märkused|Eesti|avaneb uuel vahekaardil|järgmine|tulemusi pole|üks tulemus|esita|eelmine|Muuda paanide suurust|tulemused|Otsi|väike|keskmine|suur|Jäta navigeerimine vahele|Slaid|Slaidide navigeerimine|Samm|peata|Sisukord|Suurenda|Sinine|Hele režiim|Tume režiim|Vaikimisi|Punane|Värviskeem|Türkiissinine|Kollane|Tulpdiagramm|Karpdiagramm|Diagramm|Lehterdiagramm|Seoste graaf|Soojuskaart|Joondiagramm|Kaart|Paralleelkoordinaatide diagramm|Sektordiagramm|Radardiagramm|Sankey diagramm|Hajuvusdiagramm|Tabel|Sõnapilv|Sulge vestlus|Vestlussõnum|Sul on lugemata vestlussõnumeid|Ava vestlus|Saada sõnum|Kinnitamata saatja|Koodiplokk|kopeeritud lõikelauale|kopeeri lõikelauale|Koodiredaktor|Käivita|esimene versioon|viimane versioon|maksimeeri vaade|minimeeri vaade|järgmine versioon|eelmine versioon|lähtesta sisend|töötab|Saada terminali|terminal|Peida video- ja avatarikommentaarid|Muuda hääle kõrgust|Kõrgus|Muuda taasesituse kiirust|Kiirus|Kommentaarid|Ära tugine ainult värvidele|Ava redaktor|Teave|Seaded|Jaga|jaga ... kaudu|Sisukorra sügavus|Kohtspikrid|Tõlked|Ava täisekraan|Välju täisekraanist|Avaleht|Autor: |Autorid: |Kuupäev: |E-post: |Laadi meedia alla võrguühenduseta kasutamiseks|ebaõnnestus|Meedia võrguühenduseta|Versioon: |Esitlusrežiim|Peida navigeerimine|Esitlus|Slaidid|Õpik|Veebisaidi QR-kood|Suurenda QR-koodi|Viga QR-koodi loomisel|Õiget vastust pole veel antud|Lahendatud vastus|Palju õnne, see oli õige vastus|Kontrolli|Vajuta sihtalal Enterit, et see valida, seejärel vajuta kaardil Enterit, et see sinna paigutada|Sihtala|tühi|Lünk|näita vihjet|Vastus|Kontrolli vastust. Vastus märgitakse õigeks või valeks.|Näita lahendust. Ülesanne märgitakse lahendatuks.|valik|näita lahendust|sorteeri kasvavalt|sorteeri kahanevalt|sortimata|Heli välja|Heli sisse|Enne saatmist tuleb küsimusele vastata.|Enne saatmist tuleb vastata igale reale.|Saada|Täname tagasiside eest!|Sisesta tekst...|Uuenda|Tõlgi Google'iga (eksperimentaalne)|/|Paus|Taasesituse asukoht|Eelista brauseri kõnesünteesi|Jätka|Sinu brauser ei toeta kõnesünteesi. Proovi mõnda teist brauserit.|Kasutatakse brauseri sisseehitatud kõnesünteesi."

        "hr" ->
            load "Aa|Zatvori dijalog|očisti pretragu|Stil uređivača|veličina fonta: ~|Fusnota|Fusnote|Hrvatski|otvara se u novoj kartici|sljedeće|nema rezultata|jedan rezultat|reproduciraj|prethodno|Promijeni veličinu okna|rezultati|Traži|mala|srednja|velika|Preskoči navigaciju|Slajd|Navigacija slajdova|Korak|zaustavi|Sadržaj|Povećaj|Plava|Svijetli način|Tamni način|Zadano|Crvena|Shema boja|Tirkizna|Žuta|Stupčasti grafikon|Kutijasti dijagram|Grafikon|Ljevkasti grafikon|Graf odnosa|Toplinska karta|Linijski grafikon|Karta|Dijagram paralelnih koordinata|Tortni grafikon|Radarski grafikon|Sankeyjev dijagram|Raspršeni grafikon|Tablica|Oblak riječi|Zatvori razgovor|Poruka u razgovoru|Imaš nepročitane poruke u razgovoru|Otvori razgovor|Pošalji poruku|Neprovjereni pošiljatelj|Blok koda|kopirano u međuspremnik|kopiraj u međuspremnik|Uređivač koda|Pokreni|prva verzija|posljednja verzija|maksimiziraj prikaz|minimiziraj prikaz|sljedeća verzija|prethodna verzija|poništi unos|izvodi se|Pošalji u terminal|terminal|Sakrij komentare videa i avatara|Prilagodi visinu glasa|Visina|Prilagodi brzinu reprodukcije|Brzina|Komentari|Ne oslanjaj se samo na boju|Otvori uređivač|Informacije|Postavke|Podijeli|podijeli putem ...|Dubina sadržaja|Opisi alata|Prijevodi|Uključi prikaz preko cijelog zaslona|Izađi iz prikaza preko cijelog zaslona|Početna|Autor: |Autori: |Datum: |E-pošta: |Preuzmi medije za izvanmrežnu upotrebu|neuspjelo|Mediji izvan mreže|Verzija: |Način prezentacije|Sakrij navigaciju|Prezentacija|Slajdovi|Udžbenik|QR kod za web-stranicu|Povećaj QR kod|Pogreška pri izradi QR koda|Točan odgovor još nije dan|Otkriveni odgovor|Čestitamo, to je bio točan odgovor|Provjeri|Pritisni Enter na polju za ispuštanje da ga odabereš, zatim Enter na kartici da je postaviš ondje|Polje za ispuštanje|prazno|Praznina|prikaži savjet|Odgovor|Provjeri odgovor. Odgovor će biti označen kao točan ili netočan.|Prikaži rješenje. Zadatak će biti označen kao riješen.|odabir|prikaži rješenje|sortiraj uzlazno|sortiraj silazno|nije sortirano|Isključi zvuk|Uključi zvuk|Prije slanja potrebno je odgovoriti na pitanje.|Prije slanja potrebno je odgovoriti na svaki redak.|Pošalji|Hvala na povratnim informacijama!|Unesi tekst...|Ažuriraj|Prevedi pomoću Googlea (eksperimentalno)|od|Pauziraj|Položaj reprodukcije|Daj prednost sintezi govora preglednika|Nastavi|Tvoj preglednik ne podržava sintezu govora. Isprobaj drugi.|Koristi se ugrađena sinteza govora preglednika."

        "nl" ->
            load "Aa|Dialoogvenster sluiten|Zoekopdracht wissen|editor-stijl|Lettergrootte: ~|Voetnoot|Voetnoten|Nederlands|opent in een nieuw tabblad|verder|Geen resultaten|een resultaat|afspelen|terug|Grootte van deelvensters wijzigen|Resultaten|Zoeken|klein|medium|groot|Navigatie overslaan|Dia|Dianavigatie|Stap|stoppen|Inhoudsopgave|Vergroten|blauw|lichte modus|donkere modus|standaard|rood|Kleurenschema|turkoois|geel|Staafdiagram|Boxplot|Grafiek|Trechterdiagram|Relatiegrafiek|Heatmap|Lijndiagram|Kaart|Diagram met parallelle coördinaten|Cirkeldiagram|Radardiagram|Sankeydiagram|Spreidingsdiagram|Tabel|Woordwolk|Chat sluiten|Chatbericht|Je hebt ongelezen chatberichten|Chat openen|Bericht versturen|Niet-geverifieerde afzender|Codeblok|gekopieerd naar klembord|kopiëren naar klembord|Code-editor|uitvoeren|eerste versie|laatste versie|weergave maximaliseren|weergave verkleinen|een versie vooruit|een versie terug|invoer herstellen|wordt uitgevoerd|Naar terminal sturen|terminal|Video- en avatarcommentaar verbergen|Toonhoogte aanpassen|Toon|Afspeelsnelheid aanpassen|Tempo|Commentaar|Niet alleen op kleur vertrouwen|Editor openen|Informatie|Instellingen|Delen|deel via ...|Diepte van de inhoudsopgave|Tooltips|Vertalingen|Volledig scherm|Volledig scherm verlaten|Start|Auteur: |Auteurs: |Datum: |E-mail: |Media downloaden voor offline gebruik|mislukt|Media offline|Versie: |Presentatiemodus|Navigatie verbergen|Presentatie|Dia's|Studieboek|QR-code voor website|QR-code vergroten|Fout bij het coderen naar QR-code|Het juiste antwoord is nog niet gegeven|Opgelost antwoord|Gefeliciteerd, dat was het juiste antwoord|Controleren|Druk op Enter bij een neerzetzone om die te selecteren en daarna op Enter bij een kaart om die daar te plaatsen|Neerzetzone|leeg|Invulveld|toon hint|Antwoord|Controleer het antwoord. Het antwoord wordt gemarkeerd als goed of fout.|Laat de oplossing zien. De quiz wordt gemarkeerd als opgelost.|selectie|toon oplossing|oplopend sorteren|aflopend sorteren|niet gesorteerd|Geluid uit|Geluid aan|De vraag moet vóór het verzenden worden beantwoord.|Elke rij moet vóór het verzenden worden beantwoord.|Verzenden|Bedankt voor je feedback!|Tekstinvoer ...|Bijwerken|Vertalen met Google (experimenteel)|van|Pauzeren|Afspeelpositie|Voorkeur voor browser-TTS|Hervatten|Je browser ondersteunt geen tekst-naar-spraak, probeer een andere.|De interne tekst-naar-spraak-engine van de browser wordt gebruikt."

        "sl" ->
            load "Aa|Zapri pogovorno okno|počisti iskanje|Slog urejevalnika|velikost pisave: ~|Opomba|Opombe|Slovenščina|odpre se v novem zavihku|naslednje|ni rezultatov|en rezultat|predvajaj|prejšnje|Spremeni velikost podoken|rezultati|Išči|majhna|srednja|velika|Preskoči navigacijo|Prosojnica|Navigacija po prosojnicah|Korak|ustavi|Kazalo vsebine|Povečaj|Modra|Svetli način|Temni način|Privzeto|Rdeča|Barvna shema|Turkizna|Rumena|Stolpčni grafikon|Škatla z brki|Grafikon|Lijakasti grafikon|Graf povezav|Toplotni zemljevid|Črtni grafikon|Zemljevid|Grafikon vzporednih koordinat|Tortni grafikon|Radarski grafikon|Sankeyjev diagram|Raztreseni grafikon|Tabela|Oblak besed|Zapri klepet|Sporočilo v klepetu|Imaš neprebrana sporočila v klepetu|Odpri klepet|Pošlji sporočilo|Nepreverjen pošiljatelj|Blok kode|kopirano v odložišče|kopiraj v odložišče|Urejevalnik kode|Zaženi|prva različica|zadnja različica|povečaj pogled|pomanjšaj pogled|naslednja različica|prejšnja različica|ponastavi vnos|se izvaja|Pošlji v terminal|terminal|Skrij komentarje videa in avatarja|Prilagodi višino glasu|Višina|Prilagodi hitrost predvajanja|Hitrost|Komentarji|Ne zanašaj se le na barve|Odpri urejevalnik|Informacije|Nastavitve|Deli|deli prek ...|Globina kazala|Namigi za orodja|Prevodi|Vklopi celozaslonski način|Izklopi celozaslonski način|Domov|Avtor: |Avtorji: |Datum: |E-pošta: |Prenesi medije za uporabo brez povezave|neuspešno|Mediji brez povezave|Različica: |Način predstavitve|Skrij navigacijo|Predstavitev|Prosojnice|Učbenik|Koda QR za spletno mesto|Povečaj kodo QR|Napaka pri ustvarjanju kode QR|Pravilen odgovor še ni bil podan|Razkrit odgovor|Čestitamo, to je bil pravilen odgovor|Preveri|Pritisni Enter na ciljnem polju, da ga izbereš, nato Enter na kartici, da jo postaviš tja|Ciljno polje|prazno|Vrzel|pokaži namig|Odgovor|Preveri odgovor. Odgovor bo označen kot pravilen ali napačen.|Pokaži rešitev. Naloga bo označena kot rešena.|izbira|pokaži rešitev|razvrsti naraščajoče|razvrsti padajoče|nerazvrščeno|Zvok izklopljen|Zvok vklopljen|Pred pošiljanjem je treba odgovoriti na vprašanje.|Pred pošiljanjem je treba odgovoriti v vsaki vrstici.|Pošlji|Hvala za povratne informacije!|Vnesi besedilo...|Posodobi|Prevedi z Googlom (poskusno)|od|Začasno ustavi|Položaj predvajanja|Prednostno uporabi sintezo govora v brskalniku|Nadaljuj|Tvoj brskalnik ne podpira sinteze govora. Poskusi drugega.|Uporablja se vgrajena sinteza govora v brskalniku."

        "da" ->
            load "Aa|Luk dialogboks|ryd søgning|Editorstil|skriftstørrelse: ~|Fodnote|Fodnoter|Dansk|åbner i en ny fane|næste|ingen resultater|ét resultat|afspil|forrige|Tilpas panelernes størrelse|resultater|Søg|lille|mellem|stor|Spring navigation over|Dias|Diasnavigation|Trin|stop|Indholdsfortegnelse|Forstør|Blå|Lys tilstand|Mørk tilstand|Standard|Rød|Farveskema|Turkis|Gul|Søjlediagram|Boksplot|Diagram|Tragtdiagram|Relationsgraf|Varmekort|Linjediagram|Kort|Diagram med parallelle koordinater|Cirkeldiagram|Radardiagram|Sankey-diagram|Punktdiagram|Tabel|Ordsky|Luk chatten|Chatbesked|Du har ulæste chatbeskeder|Åbn chatten|Send besked|Ubekræftet afsender|Kodeblok|kopieret til udklipsholder|kopiér til udklipsholder|Kodeeditor|Kør|første version|seneste version|maksimer visning|minimer visning|næste version|forrige version|nulstil input|kører|Send til terminal|terminal|Skjul video- og avatarkommentarer|Juster tonehøjde|Tonehøjde|Juster afspilningshastighed|Tempo|Kommentarer|Brug ikke kun farver|Åbn editoren|Information|Indstillinger|Del|del via ...|Indholdsfortegnelsens dybde|Værktøjstip|Oversættelser|Aktivér fuld skærm|Afslut fuld skærm|Hjem|Forfatter: |Forfattere: |Dato: |E-mail: |Download medier til offlinebrug|mislykkedes|Medier offline|Version: |Præsentationstilstand|Skjul navigation|Præsentation|Dias|Lærebog|QR-kode til webstedet|Forstør QR-kode|Fejl ved oprettelse af QR-kode|Det rigtige svar er endnu ikke angivet|Afsløret svar|Tillykke, det var det rigtige svar|Kontrollér|Tryk Enter på et slipfelt for at vælge det, og derefter Enter på et kort for at placere det der|Slipfelt|tomt|Hul|vis tip|Svar|Kontrollér svaret. Svaret markeres som rigtigt eller forkert.|Vis løsningen. Opgaven markeres som løst.|valg|vis løsning|sortér stigende|sortér faldende|ikke sorteret|Lyd fra|Lyd til|Spørgsmålet skal besvares inden afsendelse.|Alle rækker skal besvares inden afsendelse.|Send|Tak for din feedback!|Indtast en tekst...|Opdater|Oversæt med Google (eksperimentelt)|af|Pause|Afspilningsposition|Foretræk browserens talesyntese|Genoptag|Din browser understøtter ikke talesyntese. Prøv en anden.|Browserens indbyggede talesyntese bruges."

        "fi" ->
            load "Aa|Sulje valintaikkuna|tyhjennä haku|Editorin tyyli|fonttikoko: ~|Alaviite|Alaviitteet|Suomi|avautuu uudelle välilehdelle|seuraava|ei tuloksia|yksi tulos|toista|edellinen|Muuta ruutujen kokoa|tulokset|Hae|pieni|keskikokoinen|suuri|Ohita navigointi|Dia|Dianavigointi|Vaihe|pysäytä|Sisällysluettelo|Suurenna|Sininen|Vaalea tila|Tumma tila|Oletus|Punainen|Värimalli|Turkoosi|Keltainen|Pylväskaavio|Laatikkokaavio|Kaavio|Suppilokaavio|Suhdeverkko|Lämpökartta|Viivakaavio|Kartta|Rinnakkaiskoordinaattikaavio|Ympyräkaavio|Tutkakaavio|Sankey-kaavio|Hajontakaavio|Taulukko|Sanapilvi|Sulje keskustelu|Keskusteluviesti|Sinulla on lukemattomia keskusteluviestejä|Avaa keskustelu|Lähetä viesti|Vahvistamaton lähettäjä|Koodilohko|kopioitu leikepöydälle|kopioi leikepöydälle|Koodieditori|Suorita|ensimmäinen versio|viimeinen versio|suurenna näkymä|pienennä näkymä|seuraava versio|edellinen versio|palauta syöte|käynnissä|Lähetä päätteeseen|pääte|Piilota video- ja avatarikommentit|Säädä äänenkorkeutta|Korkeus|Säädä toistonopeutta|Nopeus|Kommentit|Älä luota pelkkiin väreihin|Avaa editori|Tiedot|Asetukset|Jaa|jaa palvelussa ...|Sisällysluettelon syvyys|Työkaluvihjeet|Käännökset|Siirry koko näytön tilaan|Poistu koko näytön tilasta|Etusivu|Tekijä: |Tekijät: |Päivämäärä: |Sähköposti: |Lataa media offline-käyttöön|epäonnistui|Media offline-tilassa|Versio: |Esitystila|Piilota navigointi|Esitys|Diat|Oppikirja|Verkkosivuston QR-koodi|Suurenna QR-koodi|Virhe QR-koodin luonnissa|Oikeaa vastausta ei ole vielä annettu|Paljastettu vastaus|Onnittelut, vastaus oli oikein|Tarkista|Valitse pudotusalue painamalla siinä Enteriä ja paina sitten kortissa Enteriä sijoittaaksesi sen sinne|Pudotusalue|tyhjä|Aukko|näytä vihje|Vastaus|Tarkista vastaus. Vastaus merkitään oikeaksi tai vääräksi.|Näytä ratkaisu. Tehtävä merkitään ratkaistuksi.|valinta|näytä ratkaisu|lajittele nousevasti|lajittele laskevasti|ei lajiteltu|Ääni pois|Ääni päälle|Kysymykseen on vastattava ennen lähettämistä.|Jokaiseen riviin on vastattava ennen lähettämistä.|Lähetä|Kiitos palautteestasi!|Kirjoita tekstiä...|Päivitä|Käännä Googlella (kokeellinen)|/|Tauko|Toistokohta|Suosi selaimen puhesynteesiä|Jatka|Selaimesi ei tue puhesynteesiä. Kokeile toista selainta.|Käytetään selaimen sisäänrakennettua puhesynteesiä."

        "fr" ->
            load "Aa|Fermer la boîte de dialogue|Effacer la recherche|Style de l'éditeur|Taille de police : ~|Note de bas de page|Notes de bas de page|Français|s'ouvre dans un nouvel onglet|suivant|aucun résultat|un résultat|Lecture|précédent|Redimensionner les volets|Résultats|Recherche|petit|moyen|grand|Passer la navigation|Diapositive|Navigation entre les diapositives|Étape|Arrêt|Table des matières|Agrandir|Bleu|Mode clair|Mode sombre|Standard|Rouge|Schéma de couleurs|Turquoise|Jaune|Diagramme en bâtons|Boîte à moustaches|Graphique|Entonnoir|Graphe de relations|Carte de chaleur|Graphique linéaire|Carte|Carte de coordonnées parallèles|Diagramme en secteurs|Graphique en radar|Diagramme de Sankey|Nuage de points|Tableau|Nuage de mots|Fermer le chat|Message de chat|Vous avez des messages de chat non lus|Ouvrir le chat|Envoyer le message|Expéditeur non vérifié|Bloc de code|Copié dans le presse-papiers|Copier dans le presse-papiers|Éditeur de code|Exécuter|première version|dernière version|Maximiser l'affichage|Réduire l'affichage|version suivante|version précédente|réinitialiser la saisie|en cours d'exécution|Envoyer au terminal|Terminal|Masquer les commentaires vidéo et avatar|Ajuster la hauteur du son|Hauteur|Ajuster la vitesse de lecture|Vitesse|Commentaires|Ne pas se fier uniquement aux couleurs|Ouvrir l'éditeur|Informations|Paramètres|Partager|Partager via ...|Profondeur de la table des matières|Infobulles|Traductions|Passer en plein écran|Quitter le plein écran|Vue d'ensemble|Auteur : |Auteurs : |Date : |Email : |Télécharger les médias pour une utilisation hors ligne|échoués|Médias hors ligne|Version : |Mode de présentation|Masquer la navigation|Présentation|Diapositives|Manuel|Code QR pour site web|Agrandir le code QR|Erreur lors de l'encodage en code QR|La réponse correcte n'a pas encore été donnée|Réponse résolue|Félicitations, c'était la bonne réponse|Vérifier|Appuyez sur Entrée sur une zone de dépôt pour la sélectionner, puis sur Entrée sur une carte pour l'y placer|Zone de dépôt|vide|Trou|Afficher l'indice|Réponse|Vérifiez la réponse. La réponse sera marquée comme correcte ou incorrecte.|Affichez la solution. Le quiz sera marqué comme résolu.|Sélection|Afficher la solution|trier par ordre croissant|trier par ordre décroissant|non trié|Haut-parleur désactivé|Haut-parleur activé|Il faut répondre à la question avant l'envoi.|Il faut répondre à chaque ligne avant l'envoi.|Soumettre|Merci pour vos commentaires !|Saisie de texte ...|Mettre à jour|Traduire avec Google (expérimental)|sur|Pause|Position de lecture|Préférer la synthèse vocale du navigateur|Reprendre|Votre navigateur ne prend pas en charge la synthèse vocale, essayez-en un autre.|Utilisation du moteur de synthèse vocale intégré du navigateur."

        "lt" ->
            load "Aa|Užverti dialogo langą|išvalyti paiešką|Rengyklės stilius|šrifto dydis: ~|Išnaša|Išnašos|Lietuvių|atsidaro naujame skirtuke|kitas|rezultatų nėra|vienas rezultatas|leisti|ankstesnis|Keisti sričių dydį|rezultatai|Ieškoti|mažas|vidutinis|didelis|Praleisti naršymą|Skaidrė|Skaidrių naršymas|Žingsnis|sustabdyti|Turinys|Padidinti|Mėlyna|Šviesus režimas|Tamsus režimas|Numatytoji|Raudona|Spalvų schema|Turkio|Geltona|Stulpelinė diagrama|Stačiakampė diagrama|Diagrama|Piltuvėlio diagrama|Ryšių grafas|Šilumos žemėlapis|Linijinė diagrama|Žemėlapis|Lygiagrečių koordinačių diagrama|Skritulinė diagrama|Radarinė diagrama|Sankey diagrama|Sklaidos diagrama|Lentelė|Žodžių debesis|Užverti pokalbį|Pokalbio žinutė|Turi neskaitytų pokalbio žinučių|Atverti pokalbį|Siųsti žinutę|Nepatvirtintas siuntėjas|Kodo blokas|nukopijuota į iškarpinę|kopijuoti į iškarpinę|Kodo rengyklė|Vykdyti|pirmoji versija|paskutinė versija|padidinti rodinį|sumažinti rodinį|kita versija|ankstesnė versija|atkurti pradinę įvestį|vykdoma|Siųsti į terminalą|terminalas|Slėpti vaizdo ir avataro komentarus|Keisti balso aukštį|Aukštis|Keisti atkūrimo greitį|Greitis|Komentarai|Nesiremti vien spalvomis|Atverti rengyklę|Informacija|Nustatymai|Bendrinti|bendrinti per ...|Turinio gylis|Paaiškinimai|Vertimai|Įjungti viso ekrano režimą|Išjungti viso ekrano režimą|Pradžia|Autorius: |Autoriai: |Data: |El. paštas: |Atsisiųsti mediją naudoti neprisijungus|nepavyko|Medija neprisijungus|Versija: |Pristatymo režimas|Slėpti naršymą|Pristatymas|Skaidrės|Vadovėlis|Svetainės QR kodas|Padidinti QR kodą|Klaida kuriant QR kodą|Teisingas atsakymas dar nepateiktas|Atskleistas atsakymas|Sveikiname, tai buvo teisingas atsakymas|Tikrinti|Paspausk Enter ant numetimo srities, kad ją pasirinktum, tada Enter ant kortelės, kad ją ten padėtum|Numetimo sritis|tuščia|Spraga|rodyti užuominą|Atsakymas|Patikrinti atsakymą. Atsakymas bus pažymėtas kaip teisingas arba neteisingas.|Parodyti sprendimą. Užduotis bus pažymėta kaip išspręsta.|pasirinkimas|rodyti sprendimą|rikiuoti didėjančiai|rikiuoti mažėjančiai|nesurikiuota|Išjungti garsą|Įjungti garsą|Prieš pateikiant būtina atsakyti į klausimą.|Prieš pateikiant būtina atsakyti į kiekvieną eilutę.|Pateikti|Dėkojame už atsiliepimą!|Įvesk tekstą...|Atnaujinti|Versti su „Google“ (eksperimentinė funkcija)|iš|Pristabdyti|Atkūrimo padėtis|Teikti pirmenybę naršyklės kalbos sintezei|Tęsti|Tavo naršyklė nepalaiko kalbos sintezės. Išbandyk kitą.|Naudojama naršyklėje integruota kalbos sintezė."

        "nb" ->
            load "Aa|Lukk dialogen|tøm søk|Editorstil|skriftstørrelse: ~|Fotnote|Fotnoter|Norsk bokmål|åpnes i en ny fane|neste|ingen resultater|ett resultat|spill av|forrige|Endre størrelse på panelene|resultater|Søk|liten|middels|stor|Hopp over navigasjonen|Lysbilde|Lysbildenavigasjon|Trinn|stopp|Innholdsfortegnelse|Forstørr|Blå|Lys modus|Mørk modus|Standard|Rød|Fargevalg|Turkis|Gul|Stolpediagram|Boksplott|Diagram|Traktdiagram|Relasjonsgraf|Varmekart|Linjediagram|Kart|Diagram med parallelle koordinater|Sektordiagram|Radardiagram|Sankey-diagram|Spredningsdiagram|Tabell|Ordsky|Lukk chatten|Chatmelding|Du har uleste chatmeldinger|Åpne chatten|Send melding|Ubekreftet avsender|Kodeblokk|kopiert til utklippstavlen|kopier til utklippstavlen|Kodeeditor|Kjør|første versjon|siste versjon|maksimer visning|minimer visning|neste versjon|forrige versjon|tilbakestill inndata|kjører|Send til terminalen|terminal|Skjul video- og avatarkommentarer|Juster tonehøyde|Tone|Juster avspillingshastighet|Tempo|Kommentarer|Ikke stol på farger alene|Åpne editoren|Informasjon|Innstillinger|Del|del via ...|Innholdsfortegnelsens dybde|Verktøytips|Oversettelser|Åpne fullskjerm|Avslutt fullskjerm|Hjem|Forfatter: |Forfattere: |Dato: |E-post: |Last ned medier for frakoblet bruk|mislyktes|Medier frakoblet|Versjon: |Presentasjonsmodus|Skjul navigasjon|Presentasjon|Lysbilder|Lærebok|QR-kode for nettstedet|Forstørr QR-koden|Feil ved oppretting av QR-kode|Riktig svar er ikke gitt ennå|Avslørt svar|Gratulerer, det var riktig svar|Kontroller|Trykk Enter på en slippsone for å velge den, og deretter Enter på et kort for å plassere det der|Slippsone|tom|Luke|vis hint|Svar|Kontroller svaret. Svaret markeres som riktig eller feil.|Vis løsningen. Oppgaven markeres som løst.|valg|vis løsning|sorter stigende|sorter synkende|ikke sortert|Lyd av|Lyd på|Spørsmålet må besvares før innsending.|Alle radene må besvares før innsending.|Send|Takk for tilbakemeldingen din!|Skriv inn tekst...|Oppdater|Oversett med Google (eksperimentelt)|av|Pause|Avspillingsposisjon|Foretrekk nettleserens talesyntese|Fortsett|Nettleseren din støtter ikke talesyntese. Prøv en annen.|Nettleserens innebygde talesyntese brukes."

        "ro" ->
            load "Aa|Închide dialogul|șterge căutarea|Stilul editorului|dimensiunea fontului: ~|Notă de subsol|Note de subsol|Română|se deschide într-o filă nouă|următorul|niciun rezultat|un rezultat|redă|anteriorul|Redimensionează panourile|rezultate|Caută|mică|medie|mare|Sari peste navigare|Diapozitiv|Navigare între diapozitive|Pas|oprește|Cuprins|Mărește|Albastru|Mod luminos|Mod întunecat|Implicit|Roșu|Schemă de culori|Turcoaz|Galben|Diagramă cu bare|Diagramă cutie|Diagramă|Diagramă pâlnie|Graf de relații|Hartă termică|Diagramă liniară|Hartă|Diagramă cu coordonate paralele|Diagramă circulară|Diagramă radar|Diagramă Sankey|Diagramă de dispersie|Tabel|Nor de cuvinte|Închide conversația|Mesaj în conversație|Ai mesaje necitite în conversație|Deschide conversația|Trimite mesajul|Expeditor neverificat|Bloc de cod|copiat în clipboard|copiază în clipboard|Editor de cod|Execută|prima versiune|ultima versiune|maximizează vizualizarea|minimizează vizualizarea|versiunea următoare|versiunea anterioară|resetează valoarea introdusă|se execută|Trimite la terminal|terminal|Ascunde comentariile video și de avatar|Ajustează înălțimea vocii|Ton|Ajustează viteza de redare|Viteză|Comentarii|Nu te baza doar pe culori|Deschide editorul|Informații|Setări|Distribuie|distribuie prin ...|Adâncimea cuprinsului|Indicații|Traduceri|Intră în modul ecran complet|Ieși din modul ecran complet|Acasă|Autor: |Autori: |Data: |E-mail: |Descarcă media pentru utilizare offline|eșuate|Media offline|Versiune: |Mod de prezentare|Ascunde navigarea|Prezentare|Diapozitive|Manual|Cod QR pentru site|Mărește codul QR|Eroare la generarea codului QR|Răspunsul corect nu a fost încă dat|Răspuns dezvăluit|Felicitări, acesta a fost răspunsul corect|Verifică|Apasă Enter pe o zonă de plasare pentru a o selecta, apoi Enter pe un card pentru a-l plasa acolo|Zonă de plasare|goală|Spațiu liber|arată indiciul|Răspuns|Verifică răspunsul. Răspunsul va fi marcat drept corect sau incorect.|Arată soluția. Exercițiul va fi marcat ca rezolvat.|selecție|arată soluția|sortează crescător|sortează descrescător|nesortat|Dezactivează sunetul|Activează sunetul|Înainte de trimitere trebuie să se răspundă la întrebare.|Înainte de trimitere trebuie să se răspundă pe fiecare rând.|Trimite|Îți mulțumim pentru feedback!|Introdu un text...|Actualizează|Tradu cu Google (experimental)|din|Întrerupe|Poziția redării|Preferă sinteza vocală a browserului|Reia|Browserul tău nu acceptă sinteza vocală. Încearcă alt browser.|Se utilizează motorul de sinteză vocală integrat în browser."

        "sv" ->
            load "Aa|Stäng dialogrutan|rensa sökning|Redigerarstil|teckenstorlek: ~|Fotnot|Fotnoter|Svenska|öppnas i en ny flik|nästa|inga resultat|ett resultat|spela upp|föregående|Ändra storlek på panelerna|resultat|Sök|liten|medelstor|stor|Hoppa över navigeringen|Bild|Bildnavigering|Steg|stoppa|Innehållsförteckning|Förstora|Blå|Ljust läge|Mörkt läge|Standard|Röd|Färgschema|Turkos|Gul|Stapeldiagram|Lådagram|Diagram|Trattdiagram|Relationsgraf|Värmekarta|Linjediagram|Karta|Diagram med parallella koordinater|Cirkeldiagram|Radardiagram|Sankeydiagram|Spridningsdiagram|Tabell|Ordmoln|Stäng chatten|Chattmeddelande|Du har olästa chattmeddelanden|Öppna chatten|Skicka meddelande|Overifierad avsändare|Kodblock|kopierat till urklipp|kopiera till urklipp|Kodredigerare|Kör|första versionen|senaste versionen|maximera vyn|minimera vyn|nästa version|föregående version|återställ inmatning|körs|Skicka till terminalen|terminal|Dölj video- och avatarkommentarer|Justera tonhöjd|Tonhöjd|Justera uppspelningshastighet|Tempo|Kommentarer|Använd inte enbart färger|Öppna redigeraren|Information|Inställningar|Dela|dela via ...|Innehållsförteckningens djup|Verktygstips|Översättningar|Aktivera helskärm|Avsluta helskärm|Hem|Författare: |Författare: |Datum: |E-post: |Ladda ner media för offlineanvändning|misslyckades|Media offline|Version: |Presentationsläge|Dölj navigering|Presentation|Bilder|Lärobok|QR-kod för webbplatsen|Förstora QR-koden|Fel när QR-koden skapades|Rätt svar har ännu inte angetts|Avslöjat svar|Grattis, det var rätt svar|Kontrollera|Tryck Enter på en släppyta för att välja den och sedan Enter på ett kort för att placera det där|Släppyta|tom|Lucka|visa ledtråd|Svar|Kontrollera svaret. Svaret markeras som rätt eller fel.|Visa lösningen. Uppgiften markeras som löst.|val|visa lösning|sortera stigande|sortera fallande|osorterat|Ljud av|Ljud på|Frågan måste besvaras före inskickning.|Alla rader måste besvaras före inskickning.|Skicka|Tack för din feedback!|Skriv en text...|Uppdatera|Översätt med Google (experimentellt)|av|Pausa|Uppspelningsposition|Föredra webbläsarens talsyntes|Fortsätt|Din webbläsare stöder inte talsyntes. Prova en annan.|Webbläsarens inbyggda talsyntes används."

        "tr" ->
            load "Aa|İletişim kutusunu kapat|aramayı temizle|Düzenleyici stili|yazı tipi boyutu: ~|Dipnot|Dipnotlar|Türkçe|yeni sekmede açılır|sonraki|sonuç yok|bir sonuç|oynat|önceki|Bölmeleri yeniden boyutlandır|sonuçlar|Ara|küçük|orta|büyük|Gezintiyi atla|Slayt|Slayt gezintisi|Adım|durdur|İçindekiler|Büyüt|Mavi|Açık mod|Koyu mod|Varsayılan|Kırmızı|Renk şeması|Turkuaz|Sarı|Çubuk grafiği|Kutu grafiği|Grafik|Huni grafiği|İlişki grafiği|Isı haritası|Çizgi grafiği|Harita|Paralel koordinat grafiği|Pasta grafiği|Radar grafiği|Sankey diyagramı|Dağılım grafiği|Tablo|Kelime bulutu|Sohbeti kapat|Sohbet mesajı|Okunmamış sohbet mesajlarınız var|Sohbeti aç|Mesaj gönder|Doğrulanmamış gönderen|Kod bloğu|panoya kopyalandı|panoya kopyala|Kod düzenleyici|Çalıştır|ilk sürüm|son sürüm|görünümü büyüt|görünümü küçült|sonraki sürüm|önceki sürüm|girişi sıfırla|çalışıyor|Terminale gönder|terminal|Video ve avatar yorumlarını gizle|Ses perdesini ayarla|Perde|Oynatma hızını ayarla|Hız|Yorumlar|Yalnızca renge güvenme|Düzenleyiciyi aç|Bilgi|Ayarlar|Paylaş|... aracılığıyla paylaş|İçindekiler derinliği|Araç ipuçları|Çeviriler|Tam ekrana geç|Tam ekrandan çık|Ana sayfa|Yazar: |Yazarlar: |Tarih: |E-posta: |Medyayı çevrimdışı kullanım için indir|başarısız|Çevrimdışı medya|Sürüm: |Sunum modu|Gezinmeyi gizle|Sunum|Slaytlar|Ders kitabı|Web sitesi için QR kodu|QR kodunu büyüt|QR kodu oluşturulurken hata oluştu|Henüz doğru yanıt verilmedi|Açıklanan yanıt|Tebrikler, doğru yanıt verdiniz|Kontrol et|Seçmek için bir bırakma alanında Enter'a, ardından oraya yerleştirmek için bir kartta Enter'a basın|Bırakma alanı|boş|Boşluk|ipucunu göster|Yanıt|Yanıtı kontrol et. Yanıt doğru veya yanlış olarak işaretlenecek.|Çözümü göster. Soru çözülmüş olarak işaretlenecek.|seçim|çözümü göster|artan sırada sırala|azalan sırada sırala|sıralanmamış|Sesi kapat|Sesi aç|Göndermeden önce soru yanıtlanmalıdır.|Göndermeden önce her satır yanıtlanmalıdır.|Gönder|Geri bildiriminiz için teşekkürler!|Bir metin girin...|Güncelle|Google ile çevir (deneysel)|/|Duraklat|Oynatma konumu|Tarayıcının metin okuma özelliğini tercih et|Devam et|Tarayıcınız metin okumayı desteklemiyor. Başka bir tarayıcı deneyin.|Tarayıcının yerleşik metin okuma motoru kullanılıyor."

        "hu" ->
            load "Aa|Párbeszédablak bezárása|keresés törlése|Szerkesztő stílusa|betűméret: ~|Lábjegyzet|Lábjegyzetek|Magyar|új lapon nyílik meg|következő|nincs találat|egy találat|lejátszás|előző|Panelek átméretezése|találatok|Keresés|kicsi|közepes|nagy|Navigáció átugrása|Dia|Dianavigáció|Lépés|leállítás|Tartalomjegyzék|Nagyítás|Kék|Világos mód|Sötét mód|Alapértelmezett|Piros|Színséma|Türkiz|Sárga|Oszlopdiagram|Dobozdiagram|Diagram|Tölcsérdiagram|Kapcsolati gráf|Hőtérkép|Vonaldiagram|Térkép|Párhuzamos koordinátadiagram|Kördiagram|Sugárdiagram|Sankey-diagram|Szórásdiagram|Táblázat|Szófelhő|Csevegés bezárása|Csevegőüzenet|Olvasatlan csevegőüzeneteid vannak|Csevegés megnyitása|Üzenet küldése|Nem ellenőrzött feladó|Kódblokk|vágólapra másolva|másolás a vágólapra|Kódszerkesztő|Futtatás|első verzió|utolsó verzió|nézet nagyítása|nézet kicsinyítése|következő verzió|előző verzió|bevitel visszaállítása|fut|Küldés a terminálba|terminál|Videós és avatar-megjegyzések elrejtése|Hangmagasság beállítása|Magasság|Lejátszási sebesség beállítása|Tempó|Megjegyzések|Ne csak a színekre hagyatkozz|Szerkesztő megnyitása|Információk|Beállítások|Megosztás|megosztás ezen keresztül: ...|Tartalomjegyzék mélysége|Eszköztippek|Fordítások|Teljes képernyő megnyitása|Kilépés a teljes képernyőből|Kezdőlap|Szerző: |Szerzők: |Dátum: |E-mail: |Médiafájlok letöltése offline használatra|sikertelen|Média offline|Verzió: |Bemutató mód|Navigáció elrejtése|Bemutató|Diák|Tankönyv|A weboldal QR-kódja|QR-kód nagyítása|Hiba a QR-kód létrehozásakor|Még nem adtad meg a helyes választ|Felfedett válasz|Gratulálunk, ez volt a helyes válasz|Ellenőrzés|Nyomj Entert egy célterületen a kiválasztásához, majd Entert egy kártyán, hogy oda helyezd|Célterület|üres|Kitöltendő hely|tipp megjelenítése|Válasz|A válasz ellenőrzése. A válasz helyesnek vagy helytelennek lesz jelölve.|A megoldás megjelenítése. A feladat megoldottként lesz jelölve.|kiválasztás|megoldás megjelenítése|növekvő rendezés|csökkenő rendezés|rendezetlen|Hang kikapcsolása|Hang bekapcsolása|Küldés előtt meg kell válaszolni a kérdést.|Küldés előtt minden sort meg kell válaszolni.|Küldés|Köszönjük a visszajelzésedet!|Írj be szöveget...|Frissítés|Fordítás a Google segítségével (kísérleti)|/|Szünet|Lejátszási pozíció|A böngésző beszédszintézisének előnyben részesítése|Folytatás|A böngésződ nem támogatja a beszédszintézist. Próbálj ki egy másikat.|A böngésző beépített beszédszintetizátora van használatban."

        "lv" ->
            load "Aa|Aizvērt dialoglodziņu|notīrīt meklēšanu|Redaktora stils|fonta lielums: ~|Vēre|Vēres|Latviešu|atveras jaunā cilnē|nākamais|nav rezultātu|viens rezultāts|atskaņot|iepriekšējais|Mainīt apgabalu izmēru|rezultāti|Meklēt|mazs|vidējs|liels|Izlaist navigāciju|Slaids|Slaidu navigācija|Solis|apturēt|Satura rādītājs|Palielināt|Zila|Gaišais režīms|Tumšais režīms|Noklusējuma|Sarkana|Krāsu shēma|Tirkīza|Dzeltena|Stabiņu diagramma|Kastveida diagramma|Diagramma|Piltuves diagramma|Saistību grafs|Siltuma karte|Līniju diagramma|Karte|Paralēlo koordinātu diagramma|Sektoru diagramma|Radara diagramma|Sankey diagramma|Izkliedes diagramma|Tabula|Vārdu mākonis|Aizvērt tērzēšanu|Tērzēšanas ziņojums|Tev ir nelasīti tērzēšanas ziņojumi|Atvērt tērzēšanu|Sūtīt ziņojumu|Nepārbaudīts sūtītājs|Koda bloks|nokopēts starpliktuvē|kopēt starpliktuvē|Koda redaktors|Izpildīt|pirmā versija|pēdējā versija|maksimizēt skatu|minimizēt skatu|nākamā versija|iepriekšējā versija|atiestatīt ievadi|tiek izpildīts|Sūtīt uz termināli|terminālis|Paslēpt video un avatāra komentārus|Pielāgot balss augstumu|Augstums|Pielāgot atskaņošanas ātrumu|Ātrums|Komentāri|Nepaļauties tikai uz krāsām|Atvērt redaktoru|Informācija|Iestatījumi|Kopīgot|kopīgot, izmantojot ...|Satura rādītāja dziļums|Rīku padomi|Tulkojumi|Ieslēgt pilnekrāna režīmu|Iziet no pilnekrāna režīma|Sākums|Autors: |Autori: |Datums: |E-pasts: |Lejupielādēt multividi lietošanai bezsaistē|neizdevās|Multivide bezsaistē|Versija: |Prezentācijas režīms|Paslēpt navigāciju|Prezentācija|Slaidi|Mācību grāmata|Vietnes QR kods|Palielināt QR kodu|Kļūda, veidojot QR kodu|Pareizā atbilde vēl nav sniegta|Atklātā atbilde|Apsveicam, tā bija pareizā atbilde|Pārbaudīt|Nospied Enter uz nomešanas zonas, lai to izvēlētos, tad Enter uz kartītes, lai to tur novietotu|Nomešanas zona|tukša|Aizpildāmā vieta|rādīt norādi|Atbilde|Pārbaudīt atbildi. Atbilde tiks atzīmēta kā pareiza vai nepareiza.|Parādīt risinājumu. Uzdevums tiks atzīmēts kā atrisināts.|izvēle|rādīt risinājumu|kārtot augošā secībā|kārtot dilstošā secībā|nav sakārtots|Izslēgt skaņu|Ieslēgt skaņu|Pirms iesniegšanas jāatbild uz jautājumu.|Pirms iesniegšanas jāatbild uz katru rindu.|Iesniegt|Paldies par atsauksmi!|Ievadi tekstu...|Atjaunināt|Tulkot ar Google (eksperimentāli)|no|Pauzēt|Atskaņošanas pozīcija|Dot priekšroku pārlūkprogrammas runas sintēzei|Turpināt|Tava pārlūkprogramma neatbalsta runas sintēzi. Izmēģini citu.|Tiek izmantota pārlūkprogrammā iebūvētā runas sintēze."

        "pl" ->
            load "Aa|Zamknij okno dialogowe|wyczyść wyszukiwanie|Styl edytora|rozmiar czcionki: ~|Przypis|Przypisy|Polski|otwiera się w nowej karcie|dalej|brak wyników|jeden wynik|odtwórz|wstecz|Zmień rozmiar paneli|wyniki|Szukaj|mały|średni|duży|Pomiń nawigację|Slajd|Nawigacja slajdów|Krok|zatrzymaj|Spis treści|Powiększ|Niebieski|Tryb jasny|Tryb ciemny|Domyślny|Czerwony|Schemat kolorów|Turkusowy|Żółty|Wykres słupkowy|Wykres pudełkowy|Wykres|Wykres lejkowy|Graf relacji|Mapa cieplna|Wykres liniowy|Mapa|Wykres współrzędnych równoległych|Wykres kołowy|Wykres radarowy|Diagram Sankeya|Wykres punktowy|Tabela|Chmura słów|Zamknij czat|Wiadomość czatu|Masz nieprzeczytane wiadomości na czacie|Otwórz czat|Wyślij wiadomość|Niezweryfikowany nadawca|Blok kodu|skopiowano do schowka|kopiuj do schowka|Edytor kodu|Uruchom|pierwsza wersja|ostatnia wersja|maksymalizuj widok|minimalizuj widok|następna wersja|poprzednia wersja|resetuj dane wejściowe|działa|Wyślij do terminala|terminal|Ukryj komentarze wideo i awatara|Dostosuj wysokość głosu|Wysokość|Dostosuj prędkość odtwarzania|Tempo|Komentarze|Nie polegaj tylko na kolorze|Otwórz edytor|Informacje|Ustawienia|Udostępnij|udostępnij przez ...|Głębokość spisu treści|Podpowiedzi|Tłumaczenia|Włącz pełny ekran|Wyłącz pełny ekran|Strona główna|Autor: |Autorzy: |Data: |E-mail: |Pobierz multimedia do użytku offline|nieudane|Multimedia offline|Wersja: |Tryb prezentacji|Ukryj nawigację|Prezentacja|Slajdy|Podręcznik|Kod QR strony internetowej|Powiększ kod QR|Błąd podczas tworzenia kodu QR|Nie podano jeszcze poprawnej odpowiedzi|Ujawniona odpowiedź|Gratulacje, to była poprawna odpowiedź|Sprawdź|Naciśnij Enter na polu upuszczania, aby je wybrać, a następnie Enter na karcie, aby ją tam umieścić|Pole upuszczania|puste|Luka|pokaż wskazówkę|Odpowiedź|Sprawdź odpowiedź. Odpowiedź zostanie oznaczona jako poprawna lub niepoprawna.|Pokaż rozwiązanie. Zadanie zostanie oznaczone jako rozwiązane.|wybór|pokaż rozwiązanie|sortuj rosnąco|sortuj malejąco|nieposortowane|Wyłącz dźwięk|Włącz dźwięk|Przed wysłaniem należy odpowiedzieć na pytanie.|Przed wysłaniem należy udzielić odpowiedzi w każdym wierszu.|Wyślij|Dziękujemy za opinię!|Wpisz tekst...|Aktualizuj|Przetłumacz za pomocą Google (eksperymentalne)|z|Wstrzymaj|Pozycja odtwarzania|Preferuj syntezę mowy przeglądarki|Wznów|Twoja przeglądarka nie obsługuje syntezy mowy. Wypróbuj inną.|Używana jest wbudowana synteza mowy przeglądarki."

        "cs" ->
            load "Aa|Zavřít dialog|vymazat hledání|Styl editoru|velikost písma: ~|Poznámka pod čarou|Poznámky pod čarou|Čeština|otevře se na nové kartě|další|žádné výsledky|jeden výsledek|přehrát|předchozí|Změnit velikost panelů|výsledky|Hledat|malá|střední|velká|Přeskočit navigaci|Snímek|Navigace mezi snímky|Krok|zastavit|Obsah|Zvětšit|Modrá|Světlý režim|Tmavý režim|Výchozí|Červená|Barevné schéma|Tyrkysová|Žlutá|Sloupcový graf|Krabicový graf|Graf|Trychtýřový graf|Graf vztahů|Tepelná mapa|Spojnicový graf|Mapa|Graf paralelních souřadnic|Výsečový graf|Paprskový graf|Sankeyův diagram|Bodový graf|Tabulka|Slovní mrak|Zavřít chat|Zpráva do chatu|Máš nepřečtené zprávy v chatu|Otevřít chat|Odeslat zprávu|Neověřený odesílatel|Blok kódu|zkopírováno do schránky|zkopírovat do schránky|Editor kódu|Spustit|první verze|poslední verze|maximalizovat zobrazení|minimalizovat zobrazení|další verze|předchozí verze|obnovit vstup|běží|Odeslat do terminálu|terminál|Skrýt komentáře videa a avatara|Upravit výšku hlasu|Výška|Upravit rychlost přehrávání|Rychlost|Komentáře|Nespoléhat jen na barvy|Otevřít editor|Informace|Nastavení|Sdílet|sdílet přes ...|Hloubka obsahu|Popisky|Překlady|Přejít na celou obrazovku|Ukončit režim celé obrazovky|Domů|Autor: |Autoři: |Datum: |E-mail: |Stáhnout média pro použití offline|selhalo|Média offline|Verze: |Režim prezentace|Skrýt navigaci|Prezentace|Snímky|Učebnice|QR kód webové stránky|Zvětšit QR kód|Chyba při vytváření QR kódu|Správná odpověď ještě nebyla zadána|Odhalená odpověď|Gratulujeme, to byla správná odpověď|Zkontrolovat|Klávesou Enter vyber cílové pole, pak klávesou Enter na kartě ji do něj umísti|Cílové pole|prázdné|Mezera|zobrazit nápovědu|Odpověď|Zkontrolovat odpověď. Odpověď bude označena jako správná nebo nesprávná.|Zobrazit řešení. Úloha bude označena jako vyřešená.|výběr|zobrazit řešení|řadit vzestupně|řadit sestupně|neseřazeno|Zvuk vypnut|Zvuk zapnut|Před odesláním je nutné odpovědět na otázku.|Před odesláním je nutné odpovědět v každém řádku.|Odeslat|Děkujeme za zpětnou vazbu!|Zadej text...|Aktualizovat|Přeložit pomocí Googlu (experimentální)|z|Pozastavit|Pozice přehrávání|Upřednostnit syntézu řeči prohlížeče|Pokračovat|Tvůj prohlížeč nepodporuje syntézu řeči. Zkus jiný.|Používá se vestavěná syntéza řeči prohlížeče."

        "sk" ->
            load "Aa|Zavrieť dialóg|vymazať vyhľadávanie|Štýl editora|veľkosť písma: ~|Poznámka pod čiarou|Poznámky pod čiarou|Slovenčina|otvorí sa na novej karte|ďalší|žiadne výsledky|jeden výsledok|prehrať|predchádzajúci|Zmeniť veľkosť panelov|výsledky|Hľadať|malá|stredná|veľká|Preskočiť navigáciu|Snímka|Navigácia snímok|Krok|zastaviť|Obsah|Zväčšiť|Modrá|Svetlý režim|Tmavý režim|Predvolené|Červená|Farebná schéma|Tyrkysová|Žltá|Stĺpcový graf|Krabicový graf|Graf|Lievikový graf|Graf vzťahov|Teplotná mapa|Čiarový graf|Mapa|Graf paralelných súradníc|Koláčový graf|Radarový graf|Sankeyho diagram|Bodový graf|Tabuľka|Oblak slov|Zavrieť čet|Správa v čete|Máš neprečítané správy v čete|Otvoriť čet|Odoslať správu|Neoverený odosielateľ|Blok kódu|skopírované do schránky|kopírovať do schránky|Editor kódu|Spustiť|prvá verzia|posledná verzia|maximalizovať zobrazenie|minimalizovať zobrazenie|ďalšia verzia|predchádzajúca verzia|obnoviť vstup|beží|Odoslať do terminálu|terminál|Skryť komentáre videa a avatara|Upraviť výšku hlasu|Výška|Upraviť rýchlosť prehrávania|Rýchlosť|Komentáre|Nespoliehať sa len na farby|Otvoriť editor|Informácie|Nastavenia|Zdieľať|zdieľať cez ...|Hĺbka obsahu|Popisy nástrojov|Preklady|Prejsť na celú obrazovku|Ukončiť režim celej obrazovky|Domov|Autor: |Autori: |Dátum: |E-mail: |Stiahnuť médiá na použitie offline|zlyhalo|Médiá offline|Verzia: |Režim prezentácie|Skryť navigáciu|Prezentácia|Snímky|Učebnica|QR kód webovej stránky|Zväčšiť QR kód|Chyba pri vytváraní QR kódu|Správna odpoveď ešte nebola zadaná|Odhalená odpoveď|Gratulujeme, to bola správna odpoveď|Skontrolovať|Stlačením Enter vyber cieľové pole, potom stlačením Enter na karte ju tam vlož|Cieľové pole|prázdne|Medzera|zobraziť nápovedu|Odpoveď|Skontrolovať odpoveď. Odpoveď bude označená ako správna alebo nesprávna.|Zobraziť riešenie. Úloha bude označená ako vyriešená.|výber|zobraziť riešenie|zoradiť vzostupne|zoradiť zostupne|nezoradené|Zvuk vypnutý|Zvuk zapnutý|Pred odoslaním je potrebné odpovedať na otázku.|Pred odoslaním je potrebné odpovedať v každom riadku.|Odoslať|Ďakujeme za spätnú väzbu!|Zadaj text...|Aktualizovať|Preložiť pomocou Googlu (experimentálne)|z|Pozastaviť|Pozícia prehrávania|Uprednostniť syntézu reči prehliadača|Pokračovať|Tvoj prehliadač nepodporuje syntézu reči. Skús iný.|Používa sa vstavaná syntéza reči prehliadača."

        "el" ->
            load "Aa|Κλείσιμο διαλόγου|εκκαθάριση αναζήτησης|Στυλ επεξεργαστή|μέγεθος γραμματοσειράς: ~|Υποσημείωση|Υποσημειώσεις|Ελληνικά|ανοίγει σε νέα καρτέλα|επόμενο|κανένα αποτέλεσμα|ένα αποτέλεσμα|αναπαραγωγή|προηγούμενο|Αλλαγή μεγέθους περιοχών|αποτελέσματα|Αναζήτηση|μικρό|μεσαίο|μεγάλο|Παράλειψη πλοήγησης|Διαφάνεια|Πλοήγηση διαφανειών|Βήμα|διακοπή|Πίνακας περιεχομένων|Μεγέθυνση|Μπλε|Φωτεινή λειτουργία|Σκοτεινή λειτουργία|Προεπιλογή|Κόκκινο|Συνδυασμός χρωμάτων|Τιρκουάζ|Κίτρινο|Ραβδόγραμμα|Θηκόγραμμα|Διάγραμμα|Διάγραμμα χοάνης|Γράφος σχέσεων|Θερμικός χάρτης|Γραμμικό διάγραμμα|Χάρτης|Διάγραμμα παράλληλων συντεταγμένων|Κυκλικό διάγραμμα|Διάγραμμα ραντάρ|Διάγραμμα Sankey|Διάγραμμα διασποράς|Πίνακας|Σύννεφο λέξεων|Κλείσιμο συνομιλίας|Μήνυμα συνομιλίας|Έχεις μη αναγνωσμένα μηνύματα συνομιλίας|Άνοιγμα συνομιλίας|Αποστολή μηνύματος|Μη επαληθευμένος αποστολέας|Μπλοκ κώδικα|αντιγράφηκε στο πρόχειρο|αντιγραφή στο πρόχειρο|Επεξεργαστής κώδικα|Εκτέλεση|πρώτη έκδοση|τελευταία έκδοση|μεγιστοποίηση προβολής|ελαχιστοποίηση προβολής|επόμενη έκδοση|προηγούμενη έκδοση|επαναφορά εισόδου|εκτελείται|Αποστολή στο τερματικό|τερματικό|Απόκρυψη σχολίων βίντεο και άβαταρ|Προσαρμογή ύψους φωνής|Τόνος|Προσαρμογή ταχύτητας αναπαραγωγής|Ταχύτητα|Σχόλια|Όχι μόνο με χρώματα|Άνοιγμα επεξεργαστή|Πληροφορίες|Ρυθμίσεις|Κοινοποίηση|κοινοποίηση μέσω ...|Βάθος πίνακα περιεχομένων|Συμβουλές εργαλείων|Μεταφράσεις|Είσοδος σε πλήρη οθόνη|Έξοδος από πλήρη οθόνη|Αρχική|Συγγραφέας: |Συγγραφείς: |Ημερομηνία: |Email: |Λήψη πολυμέσων για χρήση εκτός σύνδεσης|απέτυχαν|Πολυμέσα εκτός σύνδεσης|Έκδοση: |Λειτουργία παρουσίασης|Απόκρυψη πλοήγησης|Παρουσίαση|Διαφάνειες|Εγχειρίδιο|Κωδικός QR για τον ιστότοπο|Μεγέθυνση κωδικού QR|Σφάλμα κατά τη δημιουργία κωδικού QR|Δεν έχει δοθεί ακόμη η σωστή απάντηση|Απάντηση που αποκαλύφθηκε|Συγχαρητήρια, αυτή ήταν η σωστή απάντηση|Έλεγχος|Πάτησε Enter σε μια περιοχή απόθεσης για να την επιλέξεις και μετά Enter σε μια κάρτα για να την τοποθετήσεις εκεί|Περιοχή απόθεσης|κενή|Κενό|εμφάνιση υπόδειξης|Απάντηση|Έλεγχος της απάντησης. Η απάντηση θα επισημανθεί ως σωστή ή λανθασμένη.|Εμφάνιση της λύσης. Η άσκηση θα επισημανθεί ως λυμένη.|επιλογή|εμφάνιση λύσης|αύξουσα ταξινόμηση|φθίνουσα ταξινόμηση|χωρίς ταξινόμηση|Απενεργοποίηση ήχου|Ενεργοποίηση ήχου|Η ερώτηση πρέπει να απαντηθεί πριν από την υποβολή.|Κάθε γραμμή πρέπει να απαντηθεί πριν από την υποβολή.|Υποβολή|Ευχαριστούμε για τα σχόλιά σου!|Πληκτρολόγησε ένα κείμενο...|Ενημέρωση|Μετάφραση με το Google (πειραματικό)|από|Παύση|Θέση αναπαραγωγής|Προτίμηση σύνθεσης ομιλίας του προγράμματος περιήγησης|Συνέχεια|Το πρόγραμμα περιήγησής σου δεν υποστηρίζει σύνθεση ομιλίας. Δοκίμασε κάποιο άλλο.|Χρησιμοποιείται η ενσωματωμένη μηχανή σύνθεσης ομιλίας του προγράμματος περιήγησης."

        "bg" ->
            load "Аа|Затвори диалога|Изчистване на търсенето|редакторски стил|Размер на шрифта: ~|Бележка под линия|Бележки под линия|български|отваря се в нов раздел|Следващ|няма резултати|един резултат|Възпроизвеждане|Предишен|Преоразмеряване на панелите|Резултати|Търсене|малък|среден|голям|Пропусни навигацията|Слайд|Навигация по слайдовете|Стъпка|Спиране|Съдържание|Увеличи|Синьо|светъл режим|тъмен режим|По подразбиране|Червено|Цветова схема|Тюркоазено|Жълто|Стълбовидна диаграма|Диаграма „кутия с мустаци“|Диаграма|Фунийна диаграма|Граф на връзките|Топлинна карта|Линейна диаграма|Карта|Диаграма с паралелни координати|Кръгова диаграма|Радарна диаграма|Диаграма на Санки|Точкова диаграма|Таблица|Облак от думи|Затвори чат|Съобщение в чата|Имате непрочетени чат съобщения|Отвори чат|Изпрати съобщение|Непотвърден подател|Блок с код|Копирано в клипборда|Копирай в клипборда|Редактор на код|Изпълни|Първа версия|Последна версия|Максимизиране|Минимизиране|следваща версия|Предишна версия|нулиране на въведеното|се изпълнява|Изпрати към терминала|терминал|Скриване на коментарите с видео и аватар|Промяна на тон|Тон|Промяна на скоростта на възпроизвеждане|Скорост|Коментари|Не разчитайте само на цвета|Отвори редактор|Информация|Настройки|Споделяне|споделете чрез ...|Дълбочина на съдържанието|Подсказки|Преводи|Цял екран|Изход от цял екран|Начало|Автор: |Автори: |Дата: |Имейл: |Изтегляне на медиите за офлайн използване|неуспешни|Медии офлайн|Версия: |Режим на презентация|Скриване на навигацията|Презентация|Слайдове|Учебник|QR код за уебсайт|Увеличи QR кода|Грешка при кодирането към QR код|Все още не е даден правилният отговор|Решен отговор|Поздравления, това беше правилният отговор|Проверка|Натиснете Enter върху зона за пускане, за да я изберете, след това Enter върху карта, за да я поставите там|Зона за пускане|празна|Празно място|Покажи подсказка|Отговор|Проверете отговора. Отговорът ще бъде маркиран като правилен или неправилен.|Покажете решението. Тестът ще бъде отбелязан като решен.|избор|Покажи решението|сортиране във възходящ ред|сортиране в низходящ ред|несортирано|Звук изкл.|Звук вкл.|Преди изпращане трябва да се отговори на въпроса.|Преди изпращане трябва да се отговори на всеки ред.|Изпрати|Благодарим за обратната връзка!|Въведете текст...|Актуализирай|Превод с Google (експериментално)|от|Пауза|Позиция на възпроизвеждане|Предпочитам TTS на браузъра|Продължи|Вашият браузър не поддържа синтез на говор, опитайте с друг.|Използване на вътрешната машина за синтезиран говор на браузъра."

        "ru" ->
            load "Аа|Закрыть диалог|очистить поиск|стиль редактора|Размер шрифта: ~|Сноска|Сноски|русский|открывается в новой вкладке|вперёд|нет результатов|один результат|воспроизвести|назад|Изменить размер панелей|результаты|поиск|мелкий|средний|большой|Пропустить навигацию|Слайд|Навигация по слайдам|Шаг|остановить|оглавление|Увеличить|синий|светлый режим|темный режим|по умолчанию|красный|Цветовая схема|бирюзовый|желтый|Столбчатая диаграмма|Диаграмма размаха|Диаграмма|Диаграмма-воронка|Граф связей|Тепловая карта|Линейная диаграмма|Карта|Диаграмма параллельных координат|Круговая диаграмма|Лепестковая диаграмма|Диаграмма Санкея|Точечная диаграмма|Таблица|Облако слов|Закрыть чат|Сообщение чата|У вас есть непрочитанные сообщения в чате|Открыть чат|Отправить сообщение|Неподтверждённый отправитель|Блок кода|скопировано в буфер обмена|скопировать в буфер обмена|Редактор кода|выполнить|первая версия|последняя версия|показать полностью|свернуть|следующая версия|предыдущая версия|сбросить ввод|выполняется|Отправить в терминал|терминал|Скрыть комментарии видео и аватара|настройка высоты тона|Тон|настройка скорости воспроизведения|Скорость|Комментарии|Не полагаться только на цвет|открыть редактор|информация|настройки|поделиться|Отправить по ...|Глубина оглавления|подсказки|на других языках|перейти в полноэкранный режим|выйти из полноэкранного режима|нет войне|автор: |авторы: |дата: |эл. почта: |Скачать медиафайлы для офлайн-использования|не удалось|Медиа офлайн|версия: |режим презентации|Скрыть навигацию|презентация|слайды|учебник|QR-код для сайта|Увеличить QR-код|Ошибка при кодировании в QR-код|Правильный ответ еще не дан|Раскрытый ответ|Поздравляю, это был правильный ответ|проверить|Нажмите Enter на области размещения, чтобы выбрать её, затем Enter на карточке, чтобы поместить её туда|Область размещения|пустая|Пропуск|подсказка|Ответ|Проверьте ответ. Ответ будет отмечен как правильный или неправильный.|Показать решение. Задание будет отмечено как решённое.|выбор|показать решение|сортировать по возрастанию|сортировать по убыванию|не отсортировано|звук выключен|звук включён|Перед отправкой необходимо ответить на вопрос.|Перед отправкой необходимо ответить в каждой строке.|отправить|Спасибо за ваш отзыв!|ввод текста|Обновить|Перевести с Google (экспериментально)|из|Пауза|Позиция воспроизведения|Предпочитать браузерный TTS|Продолжить|Ваш браузер не поддерживает преобразование текста в речь, попробуйте другой.|Используется встроенный в браузер механизм преобразования текста в речь."

        "uk" ->
            load "Аа|Закрити діалог|видалити пошук|стиль редактора|Розмір шрифту: ~|Виноска|Виноски|Українська|відкривається в новій вкладці|далі|немає результатів|один результат|відтворити|назад|Змінити розмір панелей|результати|пошук|маленький|середній|великий|Пропустити навігацію|Слайд|Навігація слайдами|Крок|зупинити|зміст|Збільшити|синій|світлий режим|темний режим|стандартний|червоний|Кольорова схема|бірюзовий|жовтий|Стовпчикова діаграма|Діаграма розмаху|Діаграма|Воронкова діаграма|Граф зв'язків|Теплова карта|Лінійна діаграма|Карта|Діаграма паралельних координат|Кругова діаграма|Радарна діаграма|Діаграма Санкі|Точкова діаграма|Таблиця|Хмара слів|Закрити чат|Повідомлення чату|У вас є непрочитані повідомлення в чаті|Відкрити чат|Надіслати повідомлення|Неперевірений відправник|Блок коду|скопійовано в буфер обміну|копіювати в буфер обміну|Редактор коду|запустити|перша версія|остання версія|збільшити вигляд|зменшити вигляд|наступна версія|попередня версія|скинути введення|виконується|Надіслати в термінал|термінал|Приховати коментарі до відео та аватара|налаштування висоти тону|Тон|налаштування швидкості відтворення|Темп|Коментарі|Не покладатися лише на колір|відкрити редактор|інформація|налаштування|поділитися|поділитися через ...|Глибина змісту|підказки|переклади|увімкнути повноекранний режим|вийти з повноекранного режиму|Головна|автор: |автори: |дата: |електронна пошта: |Завантажити медіа для офлайн-використання|не вдалося|Медіа офлайн|версія: |режим презентації|Сховати навігацію|презентація|слайди|підручник|QR-код для вебсайту|Збільшити QR-код|Помилка під час кодування в QR-код|Правильна відповідь ще не надана|Вирішена відповідь|Вітаю, це була правильна відповідь|перевірити|Натисніть Enter на зоні розміщення, щоб вибрати її, потім Enter на картці, щоб розмістити її там|Зона розміщення|порожня|Пропуск|показати підказку|Відповідь|Перевірте відповідь. Відповідь буде позначено як правильну чи неправильну.|Покажіть розв’язок. Вікторину буде позначено як розв’язану.|вибір|показати розв'язок|сортувати за зростанням|сортувати за спаданням|не відсортовано|Звук вимкнено|Звук увімкнено|Перед надсиланням потрібно відповісти на запитання.|Перед надсиланням потрібно відповісти в кожному рядку.|Надіслати|Дякуємо за ваш відгук!|Введення тексту ...|Оновити|Перекласти за допомогою Google (експериментально)|з|Пауза|Позиція відтворення|Надавати перевагу TTS браузера|Продовжити|Ваш браузер не підтримує синтез мовлення з тексту, спробуйте інший.|Використання внутрішньої системи синтезу мовлення у браузері."

        "hy" ->
            load "Աա|Փակել երկխոսության պատուհանը|մաքրել որոնումը|Խմբագրիչի ոճ|Տառաչափ՝ ~|Ծանոթագրություն|Ծանոթագրություններ|հայերեն|բացվում է նոր ներդիրում|հաջորդը|արդյունք չկա|մեկ արդյունք|նվագարկել|նախորդը|Փոխել վահանակների չափը|արդյունքներ|որոնել|փոքր|միջին|մեծ|Բաց թողնել նավիգացիան|Սլայդ|Սլայդների նավիգացիա|Քայլ|կանգնեցնել|բովանդակություն|Մեծացնել|կապույտ|Բաց ռեժիմ|Մուգ ռեժիմ|կանխադրված|կարմիր|Գունային սխեմա|փիրուզագույն|դեղին|Սյունակային գծապատկեր|Արկղային գծապատկեր|Գծապատկեր|Ձագարաձև գծապատկեր|Կապերի գրաֆ|Ջերմային քարտեզ|Գծային գծապատկեր|Քարտեզ|Զուգահեռ կոորդինատների գծապատկեր|Շրջանաձև գծապատկեր|Ռադարային գծապատկեր|Սանկիի դիագրամ|Ցրման գծապատկեր|Աղյուսակ|Բառերի ամպ|Փակել զրույցը|Զրույցի հաղորդագրություն|Դուք ունեք չկարդացված հաղորդագրություններ զրույցում|Բացել զրույցը|Ուղարկել հաղորդագրությունը|Չհաստատված ուղարկող|Կոդի բլոկ|Պատճենվել է սեղմատախտակին|Պատճենել սեղմատախտակին|Կոդի խմբագրիչ|գործարկել|առաջին տարբերակը|վերջին տարբերակը|մեծացնել տեսքը|փոքրացնել տեսքը|հաջորդ տարբերակը|նախորդ տարբերակը|վերակայել մուտքագրումը|գործարկվում է|Ուղարկել տերմինալ|տերմինալ|Թաքցնել տեսանյութի և ավատարի մեկնաբանությունները|Կարգավորել ձայնի տոնը|Տոն|Կարգավորել նվագարկման արագությունը|Արագություն|Մեկնաբանություններ|Չհենվել միայն գույնի վրա|Բացել խմբագրիչը|տեղեկություններ|կարգավորումներ|կիսվել|կիսվել հետևյալ միջոցով ...|Բովանդակության խորություն|Հուշումներ|թարգմանություններ|Անցնել լիաէկրան ռեժիմի|Դուրս գալ լիաէկրան ռեժիմից|Գլխավոր|հեղինակ: |հեղինակներ: |ամսաթիվ: |էլ. փոստ: |Ներբեռնել մեդիան անցանց օգտագործման համար|ձախողվել է|Մեդիան անցանց|տարբերակ: |Ներկայացման ռեժիմ|Թաքցնել նավարկումը|ներկայացում|սլայդներ|դասագիրք|Վեբ կայքի QR կոդ|Մեծացնել QR կոդը|Սխալ QR կոդի կոդավորման ժամանակ|Ճիշտ պատասխանը դեռևս չի տրվել|Լուծված պատասխան|Շնորհավորում եմ, դա ճիշտ պատասխանն էր|ստուգել|Սեղմեք Enter տեղադրման դաշտի վրա՝ այն ընտրելու համար, ապա Enter քարտի վրա՝ այն այնտեղ տեղադրելու համար|Տեղադրման դաշտ|դատարկ|Բացթողում|ցույց տալ հուշումը|Պատասխան|Ստուգեք պատասխանը։ Այն կնշվի որպես ճիշտ կամ սխալ։|Ցույց տվեք լուծումը։ Առաջադրանքը կնշվի որպես լուծված։|ընտրություն|ցույց տալ լուծումը|դասավորել աճման կարգով|դասավորել նվազման կարգով|դասավորված չէ|առանց ձայնի|ձայնով|Ուղարկելուց առաջ պետք է պատասխանել հարցին։|Ուղարկելուց առաջ պետք է պատասխանել բոլոր տողերին։|Ուղարկել|Շնորհակալություն ձեր կարծիքի համար։|Մուտքագրեք տեքստ...|Թարմացնել|Թարգմանել Google-ի միջոցով (փորձնական)|/|Դադար|Նվագարկման դիրքը|Նախընտրել դիտարկիչի խոսքի սինթեզը|Շարունակել|Ձեր դիտարկիչը չի աջակցում խոսքի սինթեզ, փորձեք մեկ ուրիշը։|Օգտագործվում է դիտարկիչի ներկառուցված խոսքի սինթեզը։"

        "ar" ->
            load "أب|إغلاق مربع الحوار|إزالة البحث|نمط المحرر|حجم الخط: ~|حاشية|الحواشي|العربية|يفتح في علامة تبويب جديدة|التالي|لا توجد نتائج|نتيجة واحدة|تشغيل|السابق|تغيير حجم الأجزاء|النتائج|بحث|صغير|متوسط|كبير|تخطي التنقل|شريحة|التنقل بين الشرائح|خطوة|توقف|جدول المحتويات|تكبير|أزرق|الوضع الفاتح|الوضع المظلم|الافتراضي|أحمر|نظام الألوان|فيروزي|أصفر|مخطط شريطي|مخطط صندوقي|مخطط|مخطط قمعي|مخطط العلاقات|خريطة التمثيل اللوني|مخطط خطي|خريطة|مخطط الإحداثيات المتوازية|مخطط دائري|مخطط نسيجي|مخطط سانكي|مخطط مبعثر|جدول|سحابة كلمات|إغلاق الدردشة|رسالة دردشة|لديك رسائل دردشة غير مقروءة|فتح الدردشة|إرسال الرسالة|مرسل غير موثّق|كتلة شيفرة|تم النسخ إلى الحافظة|نسخ إلى الحافظة|محرر الشيفرة|تنفيذ|الإصدار الأول|أحدث إصدار|إظهار بالكامل|تصغير|الإصدار التالي|الإصدار السابق|إعادة تعيين الإدخال|قيد التشغيل|إرسال إلى الطرفية|طرفية|إخفاء تعليقات الفيديو والصورة الرمزية|تعديل طبقة الصوت|الطبقة|تعديل سرعة التشغيل|السرعة|التعليقات|عدم الاعتماد على الألوان وحدها|فتح المحرر|معلومات|الإعدادات|مشاركة|شارك عبر ...|عمق جدول المحتويات|تلميحات|الترجمات|الدخول إلى وضع ملء الشاشة|الخروج من وضع ملء الشاشة|الرئيسية|المؤلف: |المؤلفون: |التاريخ: |البريد الإلكتروني: |تنزيل الوسائط للاستخدام دون اتصال|فشل|الوسائط دون اتصال|الإصدار: |وضع العرض|إخفاء التنقل|العرض|الشرائح|الكتاب المدرسي|رمز الاستجابة السريعة للموقع|تكبير رمز الاستجابة السريعة|خطأ أثناء الترميز إلى رمز الاستجابة السريعة|لم يتم إعطاء الإجابة الصحيحة بعد|إجابة تم حلها|مبروك، هذه كانت الإجابة الصحيحة|تحقق|اضغط Enter على منطقة إفلات لتحديدها، ثم Enter على بطاقة لوضعها فيها|منطقة الإفلات|فارغة|فراغ|إظهار تلميح|الإجابة|تحقق من الإجابة. سيتم وضع علامة على الإجابة بأنها صحيحة أو غير صحيحة.|اعرض الحل. سيتم وضع علامة على الاختبار بأنه محلول.|اختيار|إظهار الحل|ترتيب تصاعدي|ترتيب تنازلي|غير مرتب|الصوت معطل|الصوت مفعل|يجب الإجابة عن السؤال قبل الإرسال.|يجب الإجابة عن كل صف قبل الإرسال.|إرسال|شكرًا على ملاحظاتك!|أدخل نصًا...|تحديث|ترجمة من جوجل (تجريبي)|من|إيقاف مؤقت|موضع التشغيل|تفضيل تحويل النص إلى كلام في المتصفح|استئناف|متصفحك لا يدعم تحويل النص إلى كلام، جرّب متصفحًا آخر.|يتم استخدام محرك تحويل النص إلى كلام المدمج في المتصفح."

        "fa" ->
            load "اب|بستن کادر محاوره|جستجو را حذف کنید|به سبک ویرایشگر|اندازه قلم: ~|پانویس|پانویس‌ها|فارسی|در زبانه جدید باز می‌شود|بعدی|هیچ نتیجه ای|یک نتیجه|پخش|قبلی|تغییر اندازهٔ بخش‌ها|نتایج|جستجو|کوچک|متوسط|بزرگ|رد شدن از پیمایش|اسلاید|پیمایش اسلایدها|مرحله|توقف|فهرست مطالب|بزرگ‌نمایی|آبی|حالت روشن|حالت تاریک|پیش‌فرض|قرمز|طرح رنگی|فیروزه‌ای|زرد|نمودار میله‌ای|نمودار جعبه‌ای|نمودار|نمودار قیفی|گراف روابط|نقشهٔ حرارتی|نمودار خطی|نقشه|نمودار مختصات موازی|نمودار دایره‌ای|نمودار راداری|نمودار سنکی|نمودار پراکندگی|جدول|ابر واژگان|بستن گفتگو|پیام گفتگو|پیام‌های گفتگوی خوانده‌نشده دارید|باز کردن گفتگو|ارسال پیام|فرستندهٔ تأییدنشده|بلوک کد|در کلیپ بورد کپی شد|کپی در کلیپ بورد|ویرایشگر کد|اجرا|نسخه اولیه|آخرین نسخه|بزرگ کردن پنجره|کوچک کردن پنجره|نسخه بعدی|نسخه قبلی|بازنشانی ورودی|در حال اجرا|ارسال به پایانه|پایانه|پنهان کردن توضیحات ویدیو و آواتار|تنظیم زیر و بمی صدا|زیر و بمی|تنظیم سرعت پخش|سرعت|توضیحات|عدم اتکا تنها به رنگ|باز کردن ویرایشگر|اطلاعات|تنظیمات|اشتراک‌گذاری|اشتراک گذاری از طریق ...|عمق فهرست مطالب|راهنمای ابزار|ترجمه ها|ورود به حالت تمام صفحه|خروج از حالت تمام صفحه|خانه|نویسنده: |نویسندگان: |تاریخ: |ایمیل: |دانلود رسانه‌ها برای استفادهٔ آفلاین|ناموفق|رسانه‌ها آفلاین|نسخه: |حالت ارائه|پنهان کردن ناوبری|ارائه|اسلایدها|کتاب درسی|کد QR برای وب سایت|بزرگ‌نمایی کد QR|خطا هنگام رمزگذاری روی کد QR|پاسخ درست هنوز داده نشده است|پاسخ حل شده|تبریک می‌گویم، پاسخ درست بود|بررسی|روی یک ناحیهٔ رهاسازی Enter را بزنید تا انتخاب شود، سپس روی یک کارت Enter را بزنید تا در آنجا قرار گیرد|ناحیهٔ رهاسازی|خالی|جای خالی|نمایش راهنمایی|پاسخ|پاسخ را بررسی کنید. پاسخ به‌عنوان درست یا نادرست علامت‌گذاری می‌شود.|راه‌حل را نشان دهید. آزمون به‌عنوان حل‌شده علامت‌گذاری می‌شود.|انتخاب|نمایش راه‌حل|مرتب‌سازی صعودی|مرتب‌سازی نزولی|مرتب‌نشده|صدا خاموش|صدا روشن|پیش از ارسال باید به پرسش پاسخ داده شود.|پیش از ارسال باید به همهٔ ردیف‌ها پاسخ داده شود.|ارسال|از بازخورد شما سپاسگزاریم!|لطفا متن وارد کنید|به‌روزرسانی|ترجمه با Google (آزمایشی)|از|مکث|موقعیت پخش|ترجیح تبدیل متن به گفتار مرورگر|ادامه|مرورگر شما از تبدیل متن به گفتار پشتیبانی نمی‌کند، مرورگر دیگری را امتحان کنید.|استفاده از موتور داخلی تبدیل متن به گفتار مرورگر."

        "ur" ->
            load "Aa|ڈائیلاگ بند کریں|تلاش صاف کریں|ایڈیٹر اسٹائل|فونٹ کا سائز: ~|حاشیہ|حواشی|اردو|نئے ٹیب میں کھلتا ہے|اگلا|کوئی نتیجہ نہیں|ایک نتیجہ|چلائیں|پچھلا|پینلز کا سائز تبدیل کریں|نتائج|تلاش|چھوٹا|درمیانہ|بڑا|نیویگیشن چھوڑیں|سلائیڈ|سلائیڈ نیویگیشن|مرحلہ|روکیں|فہرست مشمولات|بڑا کریں|نیلا|روشن موڈ|تاریک موڈ|پہلے سے طے شدہ|سرخ|رنگ سکیم|فیروزی|پیلا|بار چارٹ|باکس پلاٹ|چارٹ|فنل چارٹ|رابطہ گراف|ہیٹ میپ|لائن چارٹ|نقشہ|متوازی کوآرڈینیٹ نقشہ|پائی چارٹ|ریڈار چارٹ|سینکی ڈایاگرام|اسکیٹر پلاٹ|جدول|ورڈ کلاؤڈ|چیٹ بند کریں|چیٹ پیغام|آپ کے پاس ان پڑھے چیٹ پیغامات ہیں|چیٹ کھولیں|پیغام بھیجیں|غیر تصدیق شدہ بھیجنے والا|کوڈ بلاک|کلپ بورڈ پر کاپی ہو گیا|کلپ بورڈ پر کاپی کریں|کوڈ ایڈیٹر|چلائیں|پہلا ورژن|آخری ورژن|منظر کو بڑا کریں|منظر کو چھوٹا کریں|اگلا ورژن|پچھلا ورژن|ان پٹ ری سیٹ کریں|چل رہا ہے|ٹرمینل کو بھیجیں|ٹرمینل|ویڈیو اور اوتار تبصرے چھپائیں|آواز کی پچ ایڈجسٹ کریں|پچ|پلے بیک کی رفتار ایڈجسٹ کریں|رفتار|تبصرے|صرف رنگوں پر انحصار نہ کریں|ایڈیٹر کھولیں|معلومات|ترتیبات|شیئر کریں|... کے ذریعے شیئر کریں|فہرست مضامین کی گہرائی|ٹول ٹپس|ترجمے|پوری سکرین|پوری سکرین سے باہر|ہوم|مصنف: |مصنفین: |تاریخ: |ای میل: |آف لائن استعمال کے لیے میڈیا ڈاؤن لوڈ کریں|ناکام|میڈیا آف لائن|ورژن: |پریزنٹیشن موڈ|نیویگیشن چھپائیں|پریزنٹیشن|سلائیڈز|ٹیکسٹ بک|ویب سائٹ کے لیے QR کوڈ|QR کوڈ بڑا کریں|QR کوڈ میں انکوڈ کرتے وقت خرابی|صحیح جواب ابھی تک نہیں دیا گیا|حل شدہ جواب|مبارک ہو، یہ درست جواب تھا|چیک کریں|منتخب کرنے کے لیے کسی ڈراپ زون پر Enter دبائیں، پھر کسی کارڈ پر Enter دبا کر اسے وہاں رکھیں|ڈراپ زون|خالی|خالی جگہ|اشارہ دکھائیں|جواب|جواب چیک کریں۔ جواب کو درست یا غلط کے طور پر نشان زد کیا جائے گا۔|حل دکھائیں۔ کوئز کو حل شدہ کے طور پر نشان زد کیا جائے گا۔|انتخاب|حل دکھائیں|صعودی ترتیب|نزولی ترتیب|ترتیب نہیں دی گئی|آواز بند|آواز آن|جمع کرانے سے پہلے سوال کا جواب دیا جانا ضروری ہے۔|جمع کرانے سے پہلے ہر قطار کا جواب دیا جانا ضروری ہے۔|جمع کریں|آپ کی رائے کا شکریہ!|کچھ متن درج کریں...|اپ ڈیٹ کریں|گوگل کے ساتھ ترجمہ کریں (تجرباتی)|/|توقف|پلے بیک کی پوزیشن|براؤزر TTS کو ترجیح دیں|جاری رکھیں|آپ کا براؤزر ٹیکسٹ ٹو اسپیچ کی حمایت نہیں کرتا، کوئی دوسرا آزمائیں۔|براؤزر کے اندرونی ٹیکسٹ ٹو اسپیچ انجن کا استعمال ہو رہا ہے۔"

        "hi" ->
            load "अआ|डायलॉग बंद करें|खोज हटाएं|संपादक शैली|फ़ॉन्ट आकार: ~|फ़ुटनोट|फ़ुटनोट्स|हिन्दी|नए टैब में खुलता है|जारी रखें|कोई परिणाम नहीं|एक परिणाम|प्लेबैक|वापस|पैनल का आकार बदलें|परिणाम|खोजें|छोटा|मध्यम|बड़ा|नेविगेशन छोड़ें|स्लाइड|स्लाइड नेविगेशन|चरण|रोकें|विषय सूची|बड़ा करें|नीला|लाइट मोड|डार्क मोड|डिफ़ॉल्ट|लाल|रंग योजना|फ़िरोज़ा|पीला|बार चार्ट|बॉक्सप्लॉट|चार्ट|फ़नल चार्ट|रिलेशनशिप ग्राफ|हीटमैप|लाइन चार्ट|मैप|समानांतर समन्वय मानचित्र|पाई चार्ट|रडार चार्ट|सैंके आरेख|स्कैटरप्लॉट|तालिका|वर्ड क्लाउड|चैट बंद करें|चैट संदेश|आपके पास अपठित चैट संदेश हैं|चैट खोलें|संदेश भेजें|असत्यापित प्रेषक|कोड ब्लॉक|क्लिपबोर्ड पर कॉपी हो गया|क्लिपबोर्ड पर कॉपी करें|कोड संपादक|चलाएँ|पहला संस्करण|अंतिम संस्करण|प्रदर्शन को अधिकतम करें|प्रदर्शन को छोटा करें|अगला संस्करण|पिछला संस्करण|इनपुट रीसेट करें|चल रहा है|टर्मिनल पर भेजें|टर्मिनल|वीडियो और अवतार टिप्पणियाँ छुपाएं|पिच सेट करें|पिच|प्लेबैक गति सेट करें|गति|टिप्पणियाँ|केवल रंग पर निर्भर न रहें|संपादक खोलें|सूचना|सेटिंग्स|शेयर करें|के माध्यम से साझा करें ...|विषय-सूची की गहराई|टूलटिप्स|अनुवाद|पूर्ण स्क्रीन में जाएं|पूर्ण स्क्रीन से बाहर निकलें|सिंहावलोकन|लेखक: |लेखक: |तारीख: |ईमेल: |ऑफ़लाइन उपयोग के लिए मीडिया डाउनलोड करें|विफल|मीडिया ऑफ़लाइन|संस्करण: |प्रेजेंटेशन मोड|नेविगेशन छिपाएँ|प्रस्तुति|स्लाइड्स|पाठ्यपुस्तक|वेबसाइट के लिए क्यूआर कोड|क्यूआर कोड बड़ा करें|क्यूआर कोड को एनकोड करने में त्रुटि|अभी तक सही उत्तर नहीं दिया गया है|हल किया गया उत्तर|बधाई हो, यह सही उत्तर था|चेक करें|ड्रॉप ज़ोन चुनने के लिए उस पर Enter दबाएँ, फिर किसी कार्ड को वहाँ रखने के लिए उस पर Enter दबाएँ|ड्रॉप ज़ोन|खाली|रिक्त स्थान|संकेत दिखाएं|उत्तर|उत्तर की जाँच करें। उत्तर को सही या गलत के रूप में चिह्नित किया जाएगा।|समाधान दिखाएं। प्रश्नोत्तरी को समाधान के रूप में चिह्नित किया जाएगा।|चयन|समाधान दिखाएं|आरोही क्रमबद्ध करें|अवरोही क्रमबद्ध करें|क्रमबद्ध नहीं|स्पीकर बंद|स्पीकर ऑन|सबमिट करने से पहले प्रश्न का उत्तर दिया जाना चाहिए।|सबमिट करने से पहले हर पंक्ति का उत्तर दिया जाना चाहिए।|सबमिट करें|आपकी प्रतिक्रिया के लिए धन्यवाद!|टेक्स्ट इनपुट ...|अपडेट करें|Google के साथ अनुवाद करें (प्रायोगिक)|/|विराम|प्लेबैक स्थिति|ब्राउज़र के टेक्स्ट-टू-स्पीच को प्राथमिकता दें|फिर से शुरू करें|आपका ब्राउज़र टेक्स्ट-टू-स्पीच का समर्थन नहीं करता है, कोई दूसरा ब्राउज़र आज़माएँ।|ब्राउज़र के आंतरिक टेक्स्ट-टू-स्पीच इंजन का उपयोग किया जा रहा है।"

        "bn" ->
            load "অআ|ডায়ালগ বন্ধ করুন|অনুসন্ধান মুছে ফেলুন|সম্পাদক-স্টাইল|ফন্ট সাইজ: ~|পাদটীকা|পাদটীকাসমূহ|বাংলা|নতুন ট্যাবে খোলে|পরবর্তী|কোন ফলাফল নেই|একটি ফলাফল|চালান|পূর্ববর্তী|প্যানেলের আকার পরিবর্তন করুন|ফলাফল|অনুসন্ধান|ছোট|মাঝারি|বড়|নেভিগেশন এড়িয়ে যান|স্লাইড|স্লাইড নেভিগেশন|ধাপ|থামান|সূচী|বড় করুন|নীল|লাইট মোড|ডার্ক মোড|ডিফল্ট|লাল|রঙের স্কিম|টার্কোয়াজ|হলুদ|বার চার্ট|বক্স প্লট|চার্ট|ফানেল চার্ট|সম্পর্ক গ্রাফ|হিটম্যাপ|লাইন চার্ট|ম্যাপ|প্যারালেল কোঅর্ডিনেট ম্যাপ|পাই চার্ট|রেডার চার্ট|স্যাঙ্কি ডায়াগ্রাম|স্ক্যাটার প্লট|টেবিল|ওয়ার্ড ক্লাউড|চ্যাট বন্ধ করুন|চ্যাট বার্তা|আপনার অপঠিত চ্যাট বার্তা আছে|চ্যাট খুলুন|বার্তা পাঠান|অযাচাইকৃত প্রেরক|কোড ব্লক|ক্লিপবোর্ডে কপি করা হয়েছে|ক্লিপবোর্ডে কপি করুন|কোড এডিটর|চালান|প্রথম সংস্করণ|শেষ সংস্করণ|দৃশ্য বড় করুন|দৃশ্য ছোট করুন|পরবর্তী সংস্করণ|পূর্ববর্তী সংস্করণ|ইনপুট রিসেট করুন|চলছে|টার্মিনালে পাঠান|টার্মিনাল|ভিডিও ও অবতার মন্তব্য লুকান|স্বরের উচ্চতা সামঞ্জস্য করুন|স্বর|প্লেব্যাকের গতি সামঞ্জস্য করুন|গতি|মন্তব্য|শুধু রঙের উপর নির্ভর করবেন না|সম্পাদক খুলুন|তথ্য|সেটিংস|ভাগ করুন|এর মাধ্যমে ভাগ করুন ...|সূচিপত্রের গভীরতা|টুলটিপ|অনুবাদ|ফুলস্ক্রিনে ঢুকুন|ফুলস্ক্রিন থেকে বের হোন|হোম|লেখক: |লেখকবৃন্দ: |তারিখ: |ইমেইল: |অফলাইনে ব্যবহারের জন্য মিডিয়া ডাউনলোড করুন|ব্যর্থ|মিডিয়া অফলাইন|সংস্করণ: |প্রেজেন্টেশন মোড|নেভিগেশন লুকান|প্রেজেন্টেশন|স্লাইড|পাঠ্যবই|ওয়েবসাইটের জন্য QR কোড|QR কোড বড় করুন|QR কোডে এনকোডিং সমস্যা হয়েছে|সঠিক উত্তরটি এখনও দেওয়া হয়নি|সমাধানকৃত উত্তর|অভিনন্দন, সেটা সঠিক উত্তর ছিল|পরীক্ষা করুন|একটি ড্রপ জোন নির্বাচন করতে তাতে Enter চাপুন, তারপর একটি কার্ড সেখানে রাখতে কার্ডটিতে Enter চাপুন|ড্রপ জোন|খালি|শূন্যস্থান|ইঙ্গিত দেখান|উত্তর|উত্তরটি পরীক্ষা করুন। প্রতিক্রিয়াটি সঠিক বা ভুল হিসাবে চিহ্নিত করা হবে।|সমাধান প্রদর্শন করুন। কুইজটি সমাধানকৃত হিসাবে চিহ্নিত করা হবে।|নির্বাচন|সমাধান প্রদর্শন করুন|আরোহী ক্রমানুসারে সাজান|অবরোহী ক্রমানুসারে সাজান|সাজানো নয়|শব্দ বন্ধ|শব্দ চালু|জমা দেওয়ার আগে প্রশ্নটির উত্তর দিতে হবে।|জমা দেওয়ার আগে প্রতিটি সারির উত্তর দিতে হবে।|জমা দিন|আপনার মতামতের জন্য ধন্যবাদ!|কিছু লিখুন...|হালনাগাদ করুন|Google দিয়ে অনুবাদ করুন (পরীক্ষামূলক)|/|বিরতি|প্লেব্যাকের অবস্থান|ব্রাউজার TTS পছন্দ করুন|চালিয়ে যান|আপনার ব্রাউজার টেক্সট-টু-স্পিচ সমর্থন করে না, অন্য কোন ব্রাউজার চেষ্টা করুন।|ব্রাউজারের অভ্যন্তরীণ টেক্সট-টু-স্পিচ ইঞ্জিন ব্যবহার করা হচ্ছে।"

        "pa" ->
            load "ਅਆ|ਡਾਇਲਾਗ ਬੰਦ ਕਰੋ|ਖੋਜ ਹਟਾਓ|ਸੰਪਾਦਕ ਸਟਾਈਲ|ਫੋਂਟ ਆਕਾਰ: ~|ਫੁਟਨੋਟ|ਫੁਟਨੋਟ|ਪੰਜਾਬੀ|ਨਵੀਂ ਟੈਬ ਵਿੱਚ ਖੁੱਲ੍ਹਦਾ ਹੈ|ਅੱਗੇ|ਕੋਈ ਨਤੀਜਾ ਨਹੀਂ|ਇੱਕ ਨਤੀਜਾ|ਚਲਾਓ|ਪਿੱਛੇ|ਭਾਗਾਂ ਦਾ ਆਕਾਰ ਬਦਲੋ|ਨਤੀਜੇ|ਖੋਜ|ਛੋਟਾ|ਦਰਮਿਆਨਾ|ਵੱਡਾ|ਨੈਵੀਗੇਸ਼ਨ ਛੱਡੋ|ਸਲਾਈਡ|ਸਲਾਈਡ ਨੈਵੀਗੇਸ਼ਨ|ਕਦਮ|ਬੰਦ ਕਰੋ|ਵਿਸ਼ਾ ਸੂਚੀ|ਵੱਡਾ ਕਰੋ|ਨੀਲਾ|ਲਾਈਟ ਮੋਡ|ਡਾਰਕ ਮੋਡ|ਮੂਲ|ਲਾਲ|ਰੰਗ ਸਕੀਮ|ਫੀਰੋਜ਼ੀ|ਪੀਲਾ|ਬਾਰ ਚਾਰਟ|ਬਾਕਸਪਲਾਟ|ਚਾਰਟ|ਫਨਲ ਚਾਰਟ|ਸੰਬੰਧ ਗ੍ਰਾਫ਼|ਹੀਟਮੈਪ|ਰੇਖਾ ਚਾਰਟ|ਨਕਸ਼ਾ|ਸਮਾਂਤਰ ਕੋਆਰਡੀਨੇਟ ਚਾਰਟ|ਪਾਈ ਚਾਰਟ|ਰਾਡਾਰ ਚਾਰਟ|ਸੈਂਕੀ ਡਾਇਗ੍ਰਾਮ|ਸਕੈਟਰ ਪਲਾਟ|ਸਾਰਣੀ|ਸ਼ਬਦ ਬੱਦਲ|ਚੈਟ ਬੰਦ ਕਰੋ|ਚੈਟ ਸੁਨੇਹਾ|ਤੁਹਾਡੇ ਕੋਲ ਨਾ-ਪੜ੍ਹੇ ਚੈਟ ਸੁਨੇਹੇ ਹਨ|ਚੈਟ ਖੋਲ੍ਹੋ|ਸੁਨੇਹਾ ਭੇਜੋ|ਅਪ੍ਰਮਾਣਿਤ ਭੇਜਣ ਵਾਲਾ|ਕੋਡ ਬਲਾਕ|ਕਲਿੱਪਬੋਰਡ 'ਤੇ ਕਾਪੀ ਹੋ ਗਿਆ|ਕਲਿੱਪਬੋਰਡ 'ਤੇ ਕਾਪੀ|ਕੋਡ ਸੰਪਾਦਕ|ਚਲਾਓ|ਪਹਿਲਾ ਵਰਜਨ|ਆਖਰੀ ਵਰਜਨ|ਝਲਕ ਵੱਡੀ ਕਰੋ|ਝਲਕ ਛੋਟੀ ਕਰੋ|ਅਗਲਾ ਵਰਜਨ|ਪਿਛਲਾ ਵਰਜਨ|ਇਨਪੁਟ ਰੀਸੈੱਟ ਕਰੋ|ਚੱਲ ਰਿਹਾ ਹੈ|ਟਰਮੀਨਲ ਨੂੰ ਭੇਜੋ|ਟਰਮੀਨਲ|ਵੀਡੀਓ ਅਤੇ ਅਵਤਾਰ ਟਿੱਪਣੀਆਂ ਛੁਪਾਓ|ਸੁਰ ਸੰਰਚਨਾ|ਸੁਰ|ਪਲੇਬੈਕ ਗਤੀ ਸੰਰਚਨਾ|ਗਤੀ|ਟਿੱਪਣੀਆਂ|ਸਿਰਫ਼ ਰੰਗਾਂ 'ਤੇ ਨਿਰਭਰ ਨਾ ਕਰੋ|ਸੰਪਾਦਕ ਖੋਲ੍ਹੋ|ਜਾਣਕਾਰੀ|ਸੈਟਿੰਗਾਂ|ਸਾਂਝਾ ਕਰੋ|ਇਸ ਰਾਹੀਂ ਸਾਂਝਾ ਕਰੋ ...|ਤਤਕਰੇ ਦੀ ਡੂੰਘਾਈ|ਟੂਲਟਿੱਪ|ਅਨੁਵਾਦ|ਪੂਰੀ ਸਕ੍ਰੀਨ|ਪੂਰੀ ਸਕ੍ਰੀਨ ਤੋਂ ਬਾਹਰ|ਮੁੱਖ ਪੰਨਾ|ਲੇਖਕ: |ਲੇਖਕ: |ਮਿਤੀ: |ਈਮੇਲ: |ਔਫਲਾਈਨ ਵਰਤੋਂ ਲਈ ਮੀਡੀਆ ਡਾਊਨਲੋਡ ਕਰੋ|ਅਸਫਲ|ਮੀਡੀਆ ਔਫਲਾਈਨ|ਵਰਜਨ: |ਪ੍ਰਸਤੁਤੀ ਮੋਡ|ਨੈਵੀਗੇਸ਼ਨ ਲੁਕਾਓ|ਪ੍ਰਸਤੁਤੀ|ਸਲਾਈਡ|ਟੈਕਸਟਬੁੱਕ|ਵੈੱਬਸਾਈਟ ਲਈ QR ਕੋਡ|QR ਕੋਡ ਵੱਡਾ ਕਰੋ|QR ਕੋਡ ਨੂੰ ਏਨਕੋਡ ਕਰਨ ਦੌਰਾਨ ਗਲਤੀ ਆਈ ਹੈ|ਸਹੀ ਜਵਾਬ ਹਾਲੇ ਨਹੀਂ ਦਿੱਤਾ ਗਿਆ ਹੈ।|ਹੱਲ ਕੀਤਾ ਗਿਆ ਜਵਾਬ|ਵਧਾਈ ਹੋ, ਇਹ ਸਹੀ ਜਵਾਬ ਸੀ।|ਜਾਂਚ ਕਰੋ|ਰੱਖਣ ਵਾਲੇ ਖੇਤਰ ਨੂੰ ਚੁਣਨ ਲਈ ਉਸ 'ਤੇ Enter ਦਬਾਓ, ਫਿਰ ਕਾਰਡ ਨੂੰ ਉੱਥੇ ਰੱਖਣ ਲਈ ਕਾਰਡ 'ਤੇ Enter ਦਬਾਓ|ਰੱਖਣ ਵਾਲਾ ਖੇਤਰ|ਖਾਲੀ|ਖਾਲੀ ਥਾਂ|ਸੰਕੇਤ ਦਿਖਾਓ|ਜਵਾਬ|ਜਵਾਬ ਦੀ ਜਾਂਚ ਕਰੋ। ਜਵਾਬ ਨੂੰ ਸਹੀ ਜਾਂ ਗਲਤ ਵਜੋਂ ਨਿਸ਼ਾਨਬੱਧ ਕੀਤਾ ਜਾਵੇਗਾ।|ਹੱਲ ਦਿਖਾਓ। ਕਵਿਜ਼ ਨੂੰ ਹੱਲ ਕੀਤਾ ਵਜੋਂ ਨਿਸ਼ਾਨਬੱਧ ਕੀਤਾ ਜਾਵੇਗਾ।|ਚੋਣ|ਹੱਲ ਦਿਖਾਓ|ਵਧਦੇ ਕ੍ਰਮ ਵਿੱਚ ਕ੍ਰਮਬੱਧ ਕਰੋ|ਘਟਦੇ ਕ੍ਰਮ ਵਿੱਚ ਕ੍ਰਮਬੱਧ ਕਰੋ|ਕ੍ਰਮਬੱਧ ਨਹੀਂ|ਆਵਾਜ਼ ਬੰਦ|ਆਵਾਜ਼ ਚਾਲੂ|ਜਮ੍ਹਾਂ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਸਵਾਲ ਦਾ ਜਵਾਬ ਦਿੱਤਾ ਜਾਣਾ ਲਾਜ਼ਮੀ ਹੈ।|ਜਮ੍ਹਾਂ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਹਰ ਕਤਾਰ ਦਾ ਜਵਾਬ ਦਿੱਤਾ ਜਾਣਾ ਲਾਜ਼ਮੀ ਹੈ।|ਜਮ੍ਹਾਂ ਕਰੋ|ਤੁਹਾਡੀ ਪ੍ਰਤੀਕਿਰਿਆ ਲਈ ਧੰਨਵਾਦ!|ਕੁਝ ਟੈਕਸਟ ਦਿਓ...|ਅੱਪਡੇਟ ਕਰੋ|ਗੂਗਲ ਨਾਲ ਅਨੁਵਾਦ ਕਰੋ (ਪ੍ਰਯੋਗਾਤਮਕ)|/|ਵਿਰਾਮ|ਪਲੇਬੈਕ ਸਥਿਤੀ|ਬਰਾਊਜ਼ਰ TTS ਨੂੰ ਤਰਜੀਹ ਦਿਓ|ਜਾਰੀ ਰੱਖੋ|ਤੁਹਾਡਾ ਬਰਾਊਜ਼ਰ ਟੈਕਸਟ-ਟੁ-ਸਪੀਚ ਦਾ ਸਮਰਥਨ ਨਹੀਂ ਕਰਦਾ, ਕੋਈ ਹੋਰ ਬਰਾਊਜ਼ਰ ਵਰਤੋ।|ਬਰਾਊਜ਼ਰ ਦੇ ਅੰਦਰੂਨੀ ਟੈਕਸਟ-ਟੁ-ਸਪੀਚ ਇੰਜਨ ਦੀ ਵਰਤੋਂ ਕੀਤੀ ਜਾ ਰਹੀ ਹੈ।"

        "ka" ->
            load "Aa|დიალოგის დახურვა|ძიების გასუფთავება|რედაქტორის სტილი|შრიფტის ზომა: ~|სქოლიო|სქოლიოები|ქართული|იხსნება ახალ ჩანართში|შემდეგი|შედეგები არ არის|ერთი შედეგი|დაკვრა|წინა|არეების ზომის შეცვლა|შედეგები|ძიება|პატარა|საშუალო|დიდი|ნავიგაციის გამოტოვება|სლაიდი|სლაიდების ნავიგაცია|ნაბიჯი|გაჩერება|სარჩევი|გადიდება|ლურჯი|ნათელი რეჟიმი|მუქი რეჟიმი|ნაგულისხმევი|წითელი|ფერთა სქემა|ფირუზისფერი|ყვითელი|სვეტოვანი დიაგრამა|ყუთოვანი დიაგრამა|დიაგრამა|ძაბრისებრი დიაგრამა|კავშირების გრაფი|სითბური რუქა|ხაზოვანი დიაგრამა|რუქა|პარალელური კოორდინატების რუქა|წრიული დიაგრამა|რადარული დიაგრამა|სანკის დიაგრამა|წერტილოვანი დიაგრამა|ცხრილი|სიტყვების ღრუბელი|ჩატის დახურვა|ჩატის შეტყობინება|გაქვთ წაუკითხავი ჩატის შეტყობინებები|ჩატის გახსნა|შეტყობინების გაგზავნა|დაუდასტურებელი გამგზავნი|კოდის ბლოკი|ბუფერში დაკოპირდა|ბუფერში კოპირება|კოდის რედაქტორი|შესრულება|პირველი ვერსია|ბოლო ვერსია|მაქსიმიზაცია|მინიმიზაცია|შემდეგი ვერსია|წინა ვერსია|შეყვანის გადაყენება|მიმდინარეობს|ტერმინალში გაგზავნა|ტერმინალი|ვიდეოსა და ავატარის კომენტარების დამალვა|ტონის რეგულირება|ტონი|დაკვრის სიჩქარის რეგულირება|სიჩქარე|კომენტარები|მხოლოდ ფერებზე არ დაყრდნობა|რედაქტორის გახსნა|ინფორმაცია|პარამეტრები|გაზიარება|გაზიარება ...|სარჩევის სიღრმე|ამომხტარი მინიშნებები|თარგმანები|სრულ ეკრანზე გადასვლა|სრული ეკრანიდან გამოსვლა|მთავარი|ავტორი: |ავტორები: |თარიღი: |ელფოსტა: |მედიის ჩამოტვირთვა ხაზგარეშე გამოყენებისთვის|ვერ მოხერხდა|მედია ხაზგარეშე|ვერსია: |პრეზენტაციის რეჟიმი|ნავიგაციის დამალვა|პრეზენტაცია|სლაიდები|სახელმძღვანელო|ვებგვერდისთვის QR კოდი|QR კოდის გადიდება|შეცდომა QR კოდში კოდირებისას|სწორი პასუხი ჯერ არ არის მოწოდებული|ამოხსნილი პასუხი|გილოცავთ, ეს იყო სწორი პასუხი|შეამოწმეთ|დააჭირეთ Enter-ს ჩასაგდებ არეზე მის ასარჩევად, შემდეგ Enter-ს ბარათზე, რომ იქ მოათავსოთ|ჩასაგდები არე|ცარიელი|გამოტოვებული ადგილი|მინიშნების ჩვენება|პასუხი|შეამოწმეთ პასუხი. პასუხი მოინიშნება როგორც სწორი ან არასწორი.|ამოხსნის ჩვენება. ქვიზი მოინიშნება როგორც ამოხსნილი.|არჩევა|ამოხსნის ჩვენება|ზრდადობით დალაგება|კლებადობით დალაგება|არ არის დალაგებული|ხმა გამორთული|ხმა ჩართული|გაგზავნამდე აუცილებელია კითხვაზე პასუხის გაცემა.|გაგზავნამდე აუცილებელია ყველა სტრიქონზე პასუხის გაცემა.|გაგზავნა|გმადლობთ გამოხმაურებისთვის!|შეიყვანეთ ტექსტი...|განახლება|თარგმნა Google-ის დახმარებით (ექსპერიმენტული)|/|პაუზა|დაკვრის პოზიცია|აირჩიეთ ბრაუზერის TTS|გაგრძელება|თქვენი ბრაუზერი მხარს არ უჭერს მეტყველების სინთეზს, სცადეთ სხვა.|გამოიყენება ბრაუზერის ჩაშენებული მეტყველების სინთეზი."

        "am" ->
            load "አማ|የንግግር ሳጥን ዝጋ|ፍለጋውን አጽዳ|የአርታኢ ዘይቤ|የፊደል መጠን: ~|የግርጌ ማስታወሻ|የግርጌ ማስታወሻዎች|አማርኛ|በአዲስ ትር ውስጥ ይከፈታል|ቀጣይ|ምንም ውጤት የለም|አንድ ውጤት|አጫውት|ቀዳሚ|የክፍሎችን መጠን ቀይር|ውጤቶች|ፈልግ|ትንሽ|መካከለኛ|ትልቅ|ዳሰሳን ዝለል|ስላይድ|የስላይድ ዳሰሳ|ደረጃ|አቁም|ማውጫ|አስፋ|ሰማያዊ|ብሩህ ሁነታ|ጨለማ ሁነታ|ነባሪ|ቀይ|የቀለም ገጽታ|ቱርኩዝ|ቢጫ|የአሞሌ ገበታ|የሳጥን ገበታ|ገበታ|የማንቆርቆሪያ ገበታ|የግንኙነት ገበታ|የሙቀት ካርታ|የመስመር ገበታ|ካርታ|የትይዩ መጋጠሚያዎች ገበታ|የፓይ ገበታ|የራዳር ገበታ|የሳንኪ ገበታ|የብተና ገበታ|ሰንጠረዥ|የቃላት ደመና|ውይይት ዝጋ|የውይይት መልእክት|ያልተነበቡ የውይይት መልእክቶች አሉዎት|ውይይት ክፈት|መልእክት ላክ|ያልተረጋገጠ ላኪ|የኮድ ብሎክ|ወደ ቅንጥብ ሰሌዳ ተቀድቷል|ወደ ቅንጥብ ሰሌዳ ቅዳ|የኮድ አርታኢ|አሂድ|የመጀመሪያ ስሪት|የመጨረሻ ስሪት|እይታውን አስፋ|እይታውን አሳንስ|ቀጣይ ስሪት|ቀዳሚ ስሪት|ግቤቱን ዳግም አስጀምር|እየሄደ ነው|ወደ ተርሚናል ላክ|ተርሚናል|የቪዲዮ እና የአቫታር አስተያየቶችን ደብቅ|የድምጽ ከፍታ አስተካክል|ከፍታ|የማጫወቻ ፍጥነት አስተካክል|ፍጥነት|አስተያየቶች|በቀለም ብቻ አትመካ|አርታኢ ክፈት|መረጃ|ማስተካከያዎች|አጋራ|በ... በኩል አጋራ|የማውጫ ጥልቀት|የመሣሪያ ጥቆማዎች|ትርጉሞች|ወደ ሙሉ ማያ ገጽ ግባ|ከሙሉ ማያ ገጽ ውጣ|ዋና ገጽ|ደራሲ: |ደራሲዎች: |ቀን: |ኢሜል: |ሚዲያን ከመስመር ውጭ ለመጠቀም አውርድ|አልተሳካም|ሚዲያ ከመስመር ውጭ|ስሪት: |የአቀራረብ ሁነታ|ዳሰሳን ደብቅ|አቀራረብ|ስላይዶች|መማሪያ መጽሐፍ|QR ኮድ ለድረ ገጽ|QR ኮድ አስፋ|ወደ QR ኮድ በመቀየር ላይ ስህተት ተፈጥሯል|ትክክለኛው መልስ ገና አልተሰጠም|የተፈታ መልስ|እንኳን ደስ አለዎት፣ ይህ ትክክለኛው መልስ ነው|አረጋግጥ|ማስቀመጫ ቦታን ለመምረጥ በላዩ ላይ Enter ይጫኑ፣ ከዚያም ካርዱን እዚያ ለማስቀመጥ በካርዱ ላይ Enter ይጫኑ|ማስቀመጫ ቦታ|ባዶ|ክፍት ቦታ|ፍንጭ አሳይ|መልስ|መልሱን አረጋግጥ። መልሱ ትክክል ወይም ስህተት ተብሎ ምልክት ይደረግበታል።|መፍትሔውን አሳይ። ጥያቄው እንደተፈታ ምልክት ይደረግበታል።|ምርጫ|መፍትሔ አሳይ|ሽቅብ ደርድር|ቁልቁል ደርድር|ያልተደረደረ|ድምጽ አጥፋ|ድምጽ አብራ|ከመላኩ በፊት ጥያቄው መመለስ አለበት።|ከመላኩ በፊት እያንዳንዱ ረድፍ መመለስ አለበት።|ላክ|ለአስተያየትዎ እናመሰግናለን!|ጽሑፍ ያስገቡ...|አዘምን|በGoogle ተርጉም (የሙከራ)|ከ|ለአፍታ አቁም|የማጫወቻ ቦታ|የአሳሹን ጽሑፍ-ወደ-ንግግር ተመራጭ አድርግ|ቀጥል|አሳሽዎ ጽሑፍ-ወደ-ንግግርን አይደግፍም፤ እባክዎ ሌላ አሳሽ ይሞክሩ።|የአሳሹ ውስጣዊ ጽሑፍ-ወደ-ንግግር ሞተር ጥቅም ላይ እየዋለ ነው።"

        "ja" ->
            load "Aa|ダイアログを閉じる|検索をクリア|エディター・スタイル|フォントサイズ: ~|脚注|脚注一覧|日本語|新しいタブで開きます|次へ|結果なし|1件の結果|再生|前へ|パネルのサイズを変更|結果|検索|小|中|大|ナビゲーションをスキップ|スライド|スライドナビゲーション|ステップ|停止|目次|拡大|青|ライトモード|ダークモード|デフォルト|赤|カラースキーム|ターコイズ|黄色|棒グラフ|ボックスプロット|グラフ|ファネルチャート|関係グラフ|ヒートマップ|折れ線グラフ|地図|パラレル座標マップ|円グラフ|レーダーチャート|サンキーダイアグラム|散布図|表|ワードクラウド|チャットを閉じる|チャットメッセージ|未読のチャットメッセージがあります|チャットを開く|メッセージを送信する|未確認の送信者|コードブロック|クリップボードにコピーしました|クリップボードにコピー|コードエディター|実行|最初のバージョン|最新のバージョン|最大化|最小化|次のバージョン|前のバージョン|入力をリセット|実行中|ターミナルに送信|ターミナル|動画とアバターのコメントを非表示にする|音程を変更|音程|再生速度を変更|速度|コメント|色だけに頼らない|エディターを開く|情報|設定|共有|共有方法...|目次の深さ|ツールチップ|翻訳|フルスクリーン表示|フルスクリーンを終了する|ホーム|著者：|著者：|日付：|メール：|オフライン用にメディアをダウンロード|失敗|オフラインのメディア|バージョン：|プレゼンテーションモード|ナビゲーションを隠す|プレゼンテーション|スライド|教科書|ウェブサイト用 QR コード|QR コードを拡大|QR コードのエンコード中にエラーが発生しました|まだ正解ではありません|解決済みの回答|おめでとうございます、正解です|確認|ドロップ領域でEnterを押して選択し、次にカードでEnterを押してそこに配置します|ドロップ領域|空|空欄|ヒントを表示|回答|答えを確認してください。回答は正解または不正解でマークされます。|解答を表示します。クイズは解決済みとマークされます。|選択|解答を表示|昇順に並べ替え|降順に並べ替え|並べ替えなし|音声オフ|音声オン|送信する前に質問に回答する必要があります。|送信する前にすべての行に回答する必要があります。|送信|ご意見をお寄せいただきありがとうございます！|テキストを入力してください...|更新|Google翻訳で翻訳する（実験的）|/|一時停止|再生位置|ブラウザのTTSを優先する|再開|このブラウザはテキスト読み上げに対応していません。他のブラウザをお試しください。|ブラウザの内蔵テキスト読み上げエンジンを使用中"

        "tw" ->
            load "字|關閉對話方塊|清除搜尋|編輯器樣式|字體大小： ~|註腳|註腳|繁體中文|在新分頁中開啟|繼續|沒有結果|一個結果|播放|返回|調整窗格大小|結果|搜尋|小|中|大|跳過導覽|投影片|投影片導覽|步驟|停止|目錄|放大|藍色|亮模式|暗模式|預設|紅色|配色方案|綠松石色|黃色|長條圖|箱形圖|圖表|漏斗圖|關係圖|熱度圖|折線圖|地圖|平行座標圖|圓餅圖|雷達圖|桑基圖|散佈圖|表格|文字雲|關閉聊天室|聊天訊息|您有未讀的聊天訊息|開啟聊天室|發送訊息|未驗證的傳送者|程式碼區塊|已複製到剪貼簿|複製到剪貼簿|程式碼編輯器|開始執行|最初版|最終版|最大化顯示|最小化顯示|下一版|上一版|重設輸入|執行中|傳送至終端機|終端機|隱藏影片與虛擬形象評論|調整音高|音高|調整播放速度|速度|評論|不只依賴顏色|開啟編輯器|關於|設定|分享|透過...分享|目錄深度|工具提示|翻譯|進入全螢幕模式|退出全螢幕模式|首頁|作者: |作者: |日期: |電郵: |下載媒體以供離線使用|失敗|離線媒體|版本: |簡報模式|隱藏導覽|簡報|投影片|教科書|網站 QR 碼|放大 QR 碼|編碼為 QR 碼時出錯|正確的答案還沒有被給出|已顯示解答|恭喜，這是正確答案|檢查|在放置區按 Enter 以選取，再在卡片上按 Enter 將其放到該處|放置區|空|填空|顯示提示|答案|檢查答案。答案將被標記為正確或錯誤。|顯示解答。測驗將被標記為已解答。|選擇|顯示解答|遞增排序|遞減排序|未排序|聲音關閉|聲音開啟|提交前必須回答此問題。|提交前必須回答每一列。|提交|感謝您的回饋！|輸入文字...|更新|使用 Google 翻譯（實驗性）|/|暫停|播放位置|優先使用瀏覽器 TTS|繼續|您的瀏覽器不支援文字轉語音，請換一個瀏覽器。|正在使用瀏覽器內建的文字轉語音引擎。"

        "zh" ->
            load "字|关闭对话框|清除搜索|编辑器样式|字体大小： ~|脚注|脚注|简体中文|在新标签页中打开|下一个|没有结果|一个结果|播放|上一个|调整窗格大小|结果|搜索|小|中|大|跳过导航|幻灯片|幻灯片导航|步骤|停止|目录|放大|蓝色|浅色模式|深色模式|默认|红色|配色方案|绿松石色|黄色|柱状图|箱线图|图表|漏斗图|关系图|热力图|折线图|地图|平行坐标图|饼图|雷达图|桑基图|散点图|表格|词云|关闭聊天|聊天消息|您有未读的聊天消息|打开聊天|发送消息|未验证的发送者|代码块|已复制到剪贴板|复制到剪贴板|代码编辑器|运行|第一个版本|最后一个版本|最大化视图|最小化视图|下一版本|上一版本|重置输入|正在运行|发送到终端|终端|隐藏视频和虚拟形象讲解|调整音高|音高|调整播放速度|速度|讲解|不仅依靠颜色区分|打开编辑器|信息|设置|分享|通过……分享|目录深度|工具提示|翻译|进入全屏模式|退出全屏模式|首页|作者：|作者：|日期：|电子邮件：|下载媒体以供离线使用|失败|离线媒体|版本：|演示模式|隐藏导航|演示|幻灯片|教科书|网站二维码|放大二维码|编码为二维码时出错|尚未给出正确答案|已显示解答|恭喜，这是正确答案|检查|在放置区上按 Enter 键将其选中，然后在卡片上按 Enter 键将卡片放到那里|放置区|空|填空|显示提示|答案|检查答案。答案将被标记为正确或错误。|显示解答。测验将被标记为已解答。|选择|显示解答|升序排序|降序排序|未排序|声音关闭|声音开启|提交前必须回答此问题。|提交前必须回答每一行。|提交|感谢您的反馈！|请输入文本……|更新|使用 Google 翻译（实验性）|/|暂停|播放位置|优先使用浏览器的文本转语音|继续|您的浏览器不支持文本转语音，请换一个浏览器。|使用浏览器的内部文本转语音引擎。"

        "ko" ->
            load "가|대화 상자 닫기|입력 내용 지우기|편집기 스타일|글꼴 크기: ~|각주|각주|한국어|새 탭에서 열림|다음|결과 없음|결과 1개|재생|이전|영역 크기 조절|결과|찾기|작게|보통|크게|탐색 건너뛰기|슬라이드|슬라이드 탐색|단계|정지|목차|확대|파랑|라이트 모드|다크 모드|기본|빨강|색상 스키마|청록|노랑|막대 차트|상자 그림|차트|퍼널 차트|관계도|히트 맵|라인 차트|지도|평행 좌표 그래프|파이 차트|레이더 차트|생키 다이어그램|산점도|표|워드 클라우드|채팅 닫기|채팅 메시지|읽지 않은 채팅 메시지가 있습니다|채팅 열기|메시지 보내기|확인되지 않은 보낸 사람|코드 블록|클립보드에 복사됨|클립보드에 복사|코드 편집기|실행|첫 버전|최신 버전|뷰 최대화|뷰 최소화|다음 버전|이전 버전|입력 초기화|실행 중|터미널로 보내기|터미널|비디오 및 아바타 해설 숨기기|음높이 조절|음높이|재생 속도 조절|속도|해설|색상에만 의존하지 않기|편집기 열기|정보|설정|공유|공유하기|목차 깊이|도구 설명|번역|전체 화면으로|전체 화면에서 나가기|홈|저자: |저자: |날짜: |이메일: |오프라인용 미디어 다운로드|실패|오프라인 미디어|버전: |프레젠테이션 모드|탐색 숨기기|프레젠테이션|슬라이드|교과서|웹 사이트용 QR 코드|QR 코드 확대|QR 코드를 만드는 도중 오류가 발생했습니다.|정답이 아직 제시되지 않았습니다|정답 공개됨|축하합니다. 정답입니다|확인|드롭 영역에서 Enter 키를 눌러 선택한 다음, 카드에서 Enter 키를 눌러 그곳에 놓으세요|드롭 영역|비어 있음|빈칸|힌트 보기|답|답을 확인하세요. 정답 또는 오답으로 표시됩니다.|정답을 보여 줍니다. 퀴즈가 해결된 것으로 표시됩니다.|선택|정답 보기|오름차순 정렬|내림차순 정렬|정렬 안 됨|소리 끔|소리 켬|제출하기 전에 질문에 답해야 합니다.|제출하기 전에 모든 행에 답해야 합니다.|제출|의견을 보내 주셔서 감사합니다!|내용을 입력해주세요.|업데이트|Google Translate로 번역하기 (실험적 기능)|/|일시 정지|재생 위치|브라우저 TTS 선호|재개|이 브라우저는 텍스트 음성 변환을 지원하지 않습니다. 다른 브라우저를 사용해 보세요.|브라우저의 내부 텍스트 음성 변환 엔진을 사용합니다."

        "en" ->
            Just en

        _ ->
            Nothing


{-| Return the lowerCase language code for the given Lang.
-}
getCodeFromLn : Lang -> String
getCodeFromLn (Lang code _) =
    code


i18nGet : Int -> String -> Lang -> String
i18nGet index fallback (Lang _ texts) =
    Array.get index texts |> Maybe.withDefault fallback


{-| Put the arguments in place of the placeholders, a text may have fewer
placeholders than there are arguments.
-}
i18nFill : List String -> String -> String
i18nFill args str =
    case String.split "~" str of
        first :: rest ->
            first ++ String.concat (List.map2 (++) (args ++ List.repeat (List.length rest) "") rest)

        [] ->
            str


baseAbc : Lang -> String
baseAbc =
    i18nGet 0 "Aa"


baseCloseDialog : Lang -> String
baseCloseDialog =
    i18nGet 1 "Close dialog"


baseDelete : Lang -> String
baseDelete =
    i18nGet 2 "clear search"


baseEditor : Lang -> String
baseEditor =
    i18nGet 3 "Editor-Style"


baseFont : Lang -> String -> String
baseFont lang str0 =
    i18nFill [ str0 ] (i18nGet 4 "font size: ~" lang)


baseFootnote : Lang -> String
baseFootnote =
    i18nGet 5 "Footnote"


baseFootnotes : Lang -> String
baseFootnotes =
    i18nGet 6 "Footnotes"


baseLang : Lang -> String
baseLang =
    i18nGet 7 "English"


baseNewTab : Lang -> String
baseNewTab =
    i18nGet 8 "opens in a new tab"


baseNext : Lang -> String
baseNext =
    i18nGet 9 "next"


baseNoResult : Lang -> String
baseNoResult =
    i18nGet 10 "no results"


baseOneResult : Lang -> String
baseOneResult =
    i18nGet 11 "one result"


basePlay : Lang -> String
basePlay =
    i18nGet 12 "play"


basePrev : Lang -> String
basePrev =
    i18nGet 13 "previous"


baseResize : Lang -> String
baseResize =
    i18nGet 14 "Resize panes"


baseResults : Lang -> String
baseResults =
    i18nGet 15 "results"


baseSearch : Lang -> String
baseSearch =
    i18nGet 16 "Search"


baseSize1 : Lang -> String
baseSize1 =
    i18nGet 17 "small"


baseSize2 : Lang -> String
baseSize2 =
    i18nGet 18 "medium"


baseSize3 : Lang -> String
baseSize3 =
    i18nGet 19 "large"


baseSkipNav : Lang -> String
baseSkipNav =
    i18nGet 20 "Skip navigation"


baseSlide : Lang -> String
baseSlide =
    i18nGet 21 "Slide"


baseSlideNavigation : Lang -> String
baseSlideNavigation =
    i18nGet 22 "Slide navigation"


baseStep : Lang -> String
baseStep =
    i18nGet 23 "Step"


baseStop : Lang -> String
baseStop =
    i18nGet 24 "stop"


baseToc : Lang -> String
baseToc =
    i18nGet 25 "Table of Contents"


baseZoom : Lang -> String
baseZoom =
    i18nGet 26 "Enlarge"


cBlue : Lang -> String
cBlue =
    i18nGet 27 "Blue"


cBright : Lang -> String
cBright =
    i18nGet 28 "Light-Mode"


cDark : Lang -> String
cDark =
    i18nGet 29 "Dark-Mode"


cDefault : Lang -> String
cDefault =
    i18nGet 30 "Default"


cRed : Lang -> String
cRed =
    i18nGet 31 "Red"


cSchema : Lang -> String
cSchema =
    i18nGet 32 "Color scheme"


cTurquoise : Lang -> String
cTurquoise =
    i18nGet 33 "Turquoise"


cYellow : Lang -> String
cYellow =
    i18nGet 34 "Yellow"


chartBar : Lang -> String
chartBar =
    i18nGet 35 "Bar chart"


chartBoxplot : Lang -> String
chartBoxplot =
    i18nGet 36 "Boxplot"


chartDefault : Lang -> String
chartDefault =
    i18nGet 37 "Chart"


chartFunnel : Lang -> String
chartFunnel =
    i18nGet 38 "Funnel chart"


chartGraph : Lang -> String
chartGraph =
    i18nGet 39 "Relationship graph"


chartHeatmap : Lang -> String
chartHeatmap =
    i18nGet 40 "Heat map"


chartLine : Lang -> String
chartLine =
    i18nGet 41 "Line chart"


chartMap : Lang -> String
chartMap =
    i18nGet 42 "Map"


chartParallel : Lang -> String
chartParallel =
    i18nGet 43 "Parallel coordinate map"


chartPie : Lang -> String
chartPie =
    i18nGet 44 "Pie chart"


chartRadar : Lang -> String
chartRadar =
    i18nGet 45 "Radar chart"


chartSankey : Lang -> String
chartSankey =
    i18nGet 46 "Sankey diagram"


chartScatter : Lang -> String
chartScatter =
    i18nGet 47 "Scatter plot"


chartTable : Lang -> String
chartTable =
    i18nGet 48 "Table"


chartWordcloud : Lang -> String
chartWordcloud =
    i18nGet 49 "Word cloud"


chatClose : Lang -> String
chatClose =
    i18nGet 50 "Close chat"


chatMessage : Lang -> String
chatMessage =
    i18nGet 51 "Chat message"


chatNew : Lang -> String
chatNew =
    i18nGet 52 "You have unread chat messages"


chatOpen : Lang -> String
chatOpen =
    i18nGet 53 "Open chat"


chatSend : Lang -> String
chatSend =
    i18nGet 54 "Send message"


chatUnverified : Lang -> String
chatUnverified =
    i18nGet 55 "Unverified sender"


codeBlock : Lang -> String
codeBlock =
    i18nGet 56 "Code block"


codeCopied : Lang -> String
codeCopied =
    i18nGet 57 "copied to clipboard"


codeCopy : Lang -> String
codeCopy =
    i18nGet 58 "copy to clipboard"


codeEditor : Lang -> String
codeEditor =
    i18nGet 59 "Code editor"


codeExecute : Lang -> String
codeExecute =
    i18nGet 60 "Execute"


codeFirst : Lang -> String
codeFirst =
    i18nGet 61 "first version"


codeLast : Lang -> String
codeLast =
    i18nGet 62 "last version"


codeMaximize : Lang -> String
codeMaximize =
    i18nGet 63 "maximize view"


codeMinimize : Lang -> String
codeMinimize =
    i18nGet 64 "minimize view"


codeNext : Lang -> String
codeNext =
    i18nGet 65 "next version"


codePrev : Lang -> String
codePrev =
    i18nGet 66 "previous version"


codeReset : Lang -> String
codeReset =
    i18nGet 67 "reset input"


codeRunning : Lang -> String
codeRunning =
    i18nGet 68 "is running"


codeSendTerminal : Lang -> String
codeSendTerminal =
    i18nGet 69 "Send to terminal"


codeTerminal : Lang -> String
codeTerminal =
    i18nGet 70 "terminal"


commentHide : Lang -> String
commentHide =
    i18nGet 71 "Hide video & avatar comments"


commentPitch : Lang -> String
commentPitch =
    i18nGet 72 "Adjust pitch"


commentPitchLabel : Lang -> String
commentPitchLabel =
    i18nGet 73 "Pitch"


commentRate : Lang -> String
commentRate =
    i18nGet 74 "Adjust playback speed"


commentRateLabel : Lang -> String
commentRateLabel =
    i18nGet 75 "Speed"


commentSidebar : Lang -> String
commentSidebar =
    i18nGet 76 "Comments"


confDecals : Lang -> String
confDecals =
    i18nGet 77 "Do not rely on color alone"


confEdit : Lang -> String
confEdit =
    i18nGet 78 "Open editor"


confInformation : Lang -> String
confInformation =
    i18nGet 79 "Information"


confSettings : Lang -> String
confSettings =
    i18nGet 80 "Settings"


confShare : Lang -> String
confShare =
    i18nGet 81 "Share"


confShareVia : Lang -> String
confShareVia =
    i18nGet 82 "share via ..."


confTocDepth : Lang -> String
confTocDepth =
    i18nGet 83 "Table of contents depth"


confTooltip : Lang -> String
confTooltip =
    i18nGet 84 "Tooltips"


confTranslations : Lang -> String
confTranslations =
    i18nGet 85 "Translations"


fullscreenEnter : Lang -> String
fullscreenEnter =
    i18nGet 86 "Enter Fullscreen"


fullscreenExit : Lang -> String
fullscreenExit =
    i18nGet 87 "Exit Fullscreen"


home : Lang -> String
home =
    i18nGet 88 "Home"


infoAuthor : Lang -> String
infoAuthor =
    i18nGet 89 "Author: "


infoAuthors : Lang -> String
infoAuthors =
    i18nGet 90 "Authors: "


infoDate : Lang -> String
infoDate =
    i18nGet 91 "Date: "


infoEmail : Lang -> String
infoEmail =
    i18nGet 92 "Email: "


infoOffline : Lang -> String
infoOffline =
    i18nGet 93 "Download media for offline use"


infoOfflineFailed : Lang -> String
infoOfflineFailed =
    i18nGet 94 "failed"


infoOfflineStatus : Lang -> String
infoOfflineStatus =
    i18nGet 95 "Media offline"


infoVersion : Lang -> String
infoVersion =
    i18nGet 96 "Version: "


modeMode : Lang -> String
modeMode =
    i18nGet 97 "Presentation mode"


modeNavigation : Lang -> String
modeNavigation =
    i18nGet 98 "Hide navigation"


modePresentation : Lang -> String
modePresentation =
    i18nGet 99 "Presentation"


modeSlides : Lang -> String
modeSlides =
    i18nGet 100 "Slides"


modeTextbook : Lang -> String
modeTextbook =
    i18nGet 101 "Textbook"


qrCode : Lang -> String
qrCode =
    i18nGet 102 "QR code for website"


qrEnlarge : Lang -> String
qrEnlarge =
    i18nGet 103 "Enlarge QR code"


qrErr : Lang -> String
qrErr =
    i18nGet 104 "Error while encoding to QR code"


quizAnswerError : Lang -> String
quizAnswerError =
    i18nGet 105 "The correct answer has not yet been given"


quizAnswerResolved : Lang -> String
quizAnswerResolved =
    i18nGet 106 "Resolved answer"


quizAnswerSuccess : Lang -> String
quizAnswerSuccess =
    i18nGet 107 "Congratulations, that was the right answer"


quizCheck : Lang -> String
quizCheck =
    i18nGet 108 "Check"


quizDragHint : Lang -> String
quizDragHint =
    i18nGet 109 "Press Enter on a drop zone to select it, then Enter on a card to place it there"


quizDropZone : Lang -> String
quizDropZone =
    i18nGet 110 "Drop zone"


quizEmpty : Lang -> String
quizEmpty =
    i18nGet 111 "empty"


quizGap : Lang -> String
quizGap =
    i18nGet 112 "Gap"


quizHint : Lang -> String
quizHint =
    i18nGet 113 "show hint"


quizInput : Lang -> String
quizInput =
    i18nGet 114 "Answer"


quizLabelCheck : Lang -> String
quizLabelCheck =
    i18nGet 115 "Check the answer. The response will be marked as correct or incorrect."


quizLabelSolution : Lang -> String
quizLabelSolution =
    i18nGet 116 "Show the solution. The quiz will be marked as resolved."


quizSelection : Lang -> String
quizSelection =
    i18nGet 117 "selection"


quizSolution : Lang -> String
quizSolution =
    i18nGet 118 "show solution"


sortAsc : Lang -> String
sortAsc =
    i18nGet 119 "sort ascending"


sortDesc : Lang -> String
sortDesc =
    i18nGet 120 "sort descending"


sortNot : Lang -> String
sortNot =
    i18nGet 121 "not sorted"


soundOff : Lang -> String
soundOff =
    i18nGet 122 "Sound off"


soundOn : Lang -> String
soundOn =
    i18nGet 123 "Sound on"


surveyError : Lang -> String
surveyError =
    i18nGet 124 "This question must be answered before submitting."


surveyErrorMatrix : Lang -> String
surveyErrorMatrix =
    i18nGet 125 "Every row must be answered before submitting."


surveySubmit : Lang -> String
surveySubmit =
    i18nGet 126 "Submit"


surveySubmitted : Lang -> String
surveySubmitted =
    i18nGet 127 "Thank you for your feedback!"


surveyText : Lang -> String
surveyText =
    i18nGet 128 "Enter some text..."


surveyUpdate : Lang -> String
surveyUpdate =
    i18nGet 129 "Update"


translateWithGoogle : Lang -> String
translateWithGoogle =
    i18nGet 130 "Translate with Google (experimental)"


ttsOf : Lang -> String
ttsOf =
    i18nGet 131 "of"


ttsPause : Lang -> String
ttsPause =
    i18nGet 132 "Pause"


ttsPosition : Lang -> String
ttsPosition =
    i18nGet 133 "Playback position"


ttsPreferBrowser : Lang -> String
ttsPreferBrowser =
    i18nGet 134 "Prefer browser TTS"


ttsResume : Lang -> String
ttsResume =
    i18nGet 135 "Resume"


ttsUnsupported : Lang -> String
ttsUnsupported =
    i18nGet 136 "Your browser does not support Text-to-Speech, try another one."


ttsUsingBrowser : Lang -> String
ttsUsingBrowser =
    i18nGet 137 "Using the browser's internal Text-to-Speech engine."
