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
    case String.toLower code of
        "am" ->
            Just (i18nLoad "am" i18nAm)

        "ar" ->
            Just (i18nLoad "ar" i18nAr)

        "bg" ->
            Just (i18nLoad "bg" i18nBg)

        "bn" ->
            Just (i18nLoad "bn" i18nBn)

        "ca" ->
            Just (i18nLoad "ca" i18nCa)

        "cs" ->
            Just (i18nLoad "cs" i18nCs)

        "da" ->
            Just (i18nLoad "da" i18nDa)

        "de" ->
            Just (i18nLoad "de" i18nDe)

        "el" ->
            Just (i18nLoad "el" i18nEl)

        "es" ->
            Just (i18nLoad "es" i18nEs)

        "et" ->
            Just (i18nLoad "et" i18nEt)

        "eu" ->
            Just (i18nLoad "eu" i18nEu)

        "fa" ->
            Just (i18nLoad "fa" i18nFa)

        "fi" ->
            Just (i18nLoad "fi" i18nFi)

        "fr" ->
            Just (i18nLoad "fr" i18nFr)

        "ga" ->
            Just (i18nLoad "ga" i18nGa)

        "hi" ->
            Just (i18nLoad "hi" i18nHi)

        "hr" ->
            Just (i18nLoad "hr" i18nHr)

        "hu" ->
            Just (i18nLoad "hu" i18nHu)

        "hy" ->
            Just (i18nLoad "hy" i18nHy)

        "it" ->
            Just (i18nLoad "it" i18nIt)

        "ja" ->
            Just (i18nLoad "ja" i18nJa)

        "ka" ->
            Just (i18nLoad "ka" i18nKa)

        "ko" ->
            Just (i18nLoad "ko" i18nKo)

        "lt" ->
            Just (i18nLoad "lt" i18nLt)

        "lv" ->
            Just (i18nLoad "lv" i18nLv)

        "nb" ->
            Just (i18nLoad "nb" i18nNb)

        "nl" ->
            Just (i18nLoad "nl" i18nNl)

        "pa" ->
            Just (i18nLoad "pa" i18nPa)

        "pl" ->
            Just (i18nLoad "pl" i18nPl)

        "pt" ->
            Just (i18nLoad "pt" i18nPt)

        "ro" ->
            Just (i18nLoad "ro" i18nRo)

        "ru" ->
            Just (i18nLoad "ru" i18nRu)

        "sk" ->
            Just (i18nLoad "sk" i18nSk)

        "sl" ->
            Just (i18nLoad "sl" i18nSl)

        "sq" ->
            Just (i18nLoad "sq" i18nSq)

        "sv" ->
            Just (i18nLoad "sv" i18nSv)

        "sw" ->
            Just (i18nLoad "sw" i18nSw)

        "tr" ->
            Just (i18nLoad "tr" i18nTr)

        "tw" ->
            Just (i18nLoad "tw" i18nTw)

        "uk" ->
            Just (i18nLoad "uk" i18nUk)

        "ur" ->
            Just (i18nLoad "ur" i18nUr)

        "zh" ->
            Just (i18nLoad "zh" i18nZh)

        "en" ->
            Just en

        _ ->
            Nothing


{-| Return the lowerCase language code for the given Lang.
-}
getCodeFromLn : Lang -> String
getCodeFromLn (Lang code _) =
    code


i18nLoad : String -> String -> Lang
i18nLoad code texts =
    Lang code (Array.fromList (String.split "\u{001F}" texts))


i18nGet : Int -> String -> Lang -> String
i18nGet index fallback (Lang _ texts) =
    Array.get index texts |> Maybe.withDefault fallback


{-| Put the arguments in place of the placeholders.
-}
i18nFill : List String -> String -> String
i18nFill args str =
    let
        parts =
            String.split "\u{001E}" str
    in
    List.map2 (++) parts (args ++ List.repeat (List.length parts) "")
        |> String.concat


i18nAm : String
i18nAm =
    "አማ\u{001F}የንግግር ሳጥን ዝጋ\u{001F}ፍለጋውን አጽዳ\u{001F}የአርታኢ ዘይቤ\u{001F}የፊደል መጠን: \u{001E}\u{001F}የግርጌ ማስታወሻ\u{001F}የግርጌ ማስታወሻዎች\u{001F}አማርኛ\u{001F}በአዲስ ትር ውስጥ ይከፈታል\u{001F}ቀጣይ\u{001F}ምንም ውጤት የለም\u{001F}አንድ ውጤት\u{001F}አጫውት\u{001F}ቀዳሚ\u{001F}የክፍሎችን መጠን ቀይር\u{001F}ውጤቶች\u{001F}ፈልግ\u{001F}ትንሽ\u{001F}መካከለኛ\u{001F}ትልቅ\u{001F}ዳሰሳን ዝለል\u{001F}ስላይድ\u{001F}የስላይድ ዳሰሳ\u{001F}ደረጃ\u{001F}አቁም\u{001F}ማውጫ\u{001F}አስፋ\u{001F}ሰማያዊ\u{001F}ብሩህ ሁነታ\u{001F}ቀለም\u{001F}ጨለማ ሁነታ\u{001F}ነባሪ\u{001F}ቀይ\u{001F}የቀለም ገጽታ\u{001F}ቱርኩዝ\u{001F}ቢጫ\u{001F}የአሞሌ ገበታ\u{001F}የሳጥን ገበታ\u{001F}ገበታ\u{001F}የማንቆርቆሪያ ገበታ\u{001F}የግንኙነት ገበታ\u{001F}የሙቀት ካርታ\u{001F}የመስመር ገበታ\u{001F}የመስመሮች ገበታ\u{001F}ካርታ\u{001F}የትይዩ መጋጠሚያዎች ገበታ\u{001F}የፓይ ገበታ\u{001F}የራዳር ገበታ\u{001F}የሳንኪ ገበታ\u{001F}የብተና ገበታ\u{001F}ሰንጠረዥ\u{001F}የቃላት ደመና\u{001F}ውይይት ዝጋ\u{001F}የውይይት መልእክት\u{001F}ያልተነበቡ የውይይት መልእክቶች አሉዎት\u{001F}ውይይት ክፈት\u{001F}መልእክት ላክ\u{001F}ያልተረጋገጠ ላኪ\u{001F}የኮድ ብሎክ\u{001F}ወደ ቅንጥብ ሰሌዳ ተቀድቷል\u{001F}ወደ ቅንጥብ ሰሌዳ ቅዳ\u{001F}የኮድ አርታኢ\u{001F}አሂድ\u{001F}የመጀመሪያ ስሪት\u{001F}የመጨረሻ ስሪት\u{001F}እይታውን አስፋ\u{001F}እይታውን አሳንስ\u{001F}ቀጣይ ስሪት\u{001F}ቀዳሚ ስሪት\u{001F}ግቤቱን ዳግም አስጀምር\u{001F}እየሄደ ነው\u{001F}ወደ ተርሚናል ላክ\u{001F}ተርሚናል\u{001F}የቪዲዮ እና የአቫታር አስተያየቶችን ደብቅ\u{001F}የድምጽ ከፍታ አስተካክል\u{001F}ከፍታ\u{001F}የማጫወቻ ፍጥነት አስተካክል\u{001F}ፍጥነት\u{001F}አስተያየቶች\u{001F}በቀለም ብቻ አትመካ\u{001F}አርታኢ ክፈት\u{001F}መረጃ\u{001F}ማስተካከያዎች\u{001F}አጋራ\u{001F}በ... በኩል አጋራ\u{001F}የመሣሪያ ጥቆማዎች\u{001F}ትርጉሞች\u{001F}ወደ ሙሉ ማያ ገጽ ግባ\u{001F}ከሙሉ ማያ ገጽ ውጣ\u{001F}ዋና ገጽ\u{001F}ደራሲ: \u{001F}ደራሲዎች: \u{001F}ቀን: \u{001F}ኢሜል: \u{001F}ሚዲያን ከመስመር ውጭ ለመጠቀም አውርድ\u{001F}አልተሳካም\u{001F}ሚዲያ ከመስመር ውጭ\u{001F}ስሪት: \u{001F}የአቀራረብ ሁነታ\u{001F}ዳሰሳን ደብቅ\u{001F}አቀራረብ\u{001F}ስላይዶች\u{001F}መማሪያ መጽሐፍ\u{001F}እስካሁን ምንም ትርጉም የለም\u{001F}QR ኮድ ለድረ ገጽ\u{001F}QR ኮድ አስፋ\u{001F}ወደ QR ኮድ በመቀየር ላይ ስህተት ተፈጥሯል\u{001F}ትክክለኛው መልስ ገና አልተሰጠም\u{001F}የተፈታ መልስ\u{001F}እንኳን ደስ አለዎት፣ ይህ ትክክለኛው መልስ ነው\u{001F}አረጋግጥ\u{001F}ማስቀመጫ ቦታን ለመምረጥ በላዩ ላይ Enter ይጫኑ፣ ከዚያም ካርዱን እዚያ ለማስቀመጥ በካርዱ ላይ Enter ይጫኑ\u{001F}ማስቀመጫ ቦታ\u{001F}ባዶ\u{001F}ክፍት ቦታ\u{001F}ፍንጭ አሳይ\u{001F}መልስ\u{001F}መልሱን አረጋግጥ። መልሱ ትክክል ወይም ስህተት ተብሎ ምልክት ይደረግበታል።\u{001F}መፍትሔውን አሳይ። ጥያቄው እንደተፈታ ምልክት ይደረግበታል።\u{001F}ምርጫ\u{001F}መፍትሔ አሳይ\u{001F}ሽቅብ ደርድር\u{001F}ቁልቁል ደርድር\u{001F}ያልተደረደረ\u{001F}ድምጽ አጥፋ\u{001F}ድምጽ አብራ\u{001F}ከመላኩ በፊት ጥያቄው መመለስ አለበት።\u{001F}ከመላኩ በፊት እያንዳንዱ ረድፍ መመለስ አለበት።\u{001F}ላክ\u{001F}ለአስተያየትዎ እናመሰግናለን!\u{001F}ጽሑፍ ያስገቡ...\u{001F}አዘምን\u{001F}በGoogle ተርጉም (የሙከራ)\u{001F}ከ\u{001F}ለአፍታ አቁም\u{001F}የማጫወቻ ቦታ\u{001F}የአሳሹን ጽሑፍ-ወደ-ንግግር ተመራጭ አድርግ\u{001F}ቀጥል\u{001F}አሳሽዎ ጽሑፍ-ወደ-ንግግርን አይደግፍም፤ እባክዎ ሌላ አሳሽ ይሞክሩ።\u{001F}የአሳሹ ውስጣዊ ጽሑፍ-ወደ-ንግግር ሞተር ጥቅም ላይ እየዋለ ነው።"


i18nAr : String
i18nAr =
    "أب\u{001F}إغلاق مربع الحوار\u{001F}إزالة البحث\u{001F}نمط المحرر\u{001F}حجم الخط: \u{001E}\u{001F}حاشية\u{001F}الحواشي\u{001F}العربية\u{001F}يفتح في علامة تبويب جديدة\u{001F}التالي\u{001F}لا توجد نتائج\u{001F}نتيجة واحدة\u{001F}تشغيل\u{001F}السابق\u{001F}تغيير حجم الأجزاء\u{001F}النتائج\u{001F}بحث\u{001F}صغير\u{001F}متوسط\u{001F}كبير\u{001F}تخطي التنقل\u{001F}شريحة\u{001F}التنقل بين الشرائح\u{001F}خطوة\u{001F}توقف\u{001F}جدول المحتويات\u{001F}تكبير\u{001F}أزرق\u{001F}الوضع الفاتح\u{001F}لون\u{001F}الوضع المظلم\u{001F}الافتراضي\u{001F}أحمر\u{001F}نظام الألوان\u{001F}فيروزي\u{001F}أصفر\u{001F}مخطط شريطي\u{001F}مخطط صندوقي\u{001F}مخطط\u{001F}مخطط قمعي\u{001F}مخطط العلاقات\u{001F}خريطة التمثيل اللوني\u{001F}مخطط خطي\u{001F}رسم بياني خطي\u{001F}خريطة\u{001F}مخطط الإحداثيات المتوازية\u{001F}مخطط دائري\u{001F}مخطط نسيجي\u{001F}مخطط سانكي\u{001F}مخطط مبعثر\u{001F}جدول\u{001F}سحابة كلمات\u{001F}إغلاق الدردشة\u{001F}رسالة دردشة\u{001F}لديك رسائل دردشة غير مقروءة\u{001F}فتح الدردشة\u{001F}إرسال الرسالة\u{001F}مرسل غير موثّق\u{001F}كتلة شيفرة\u{001F}تم النسخ إلى الحافظة\u{001F}نسخ إلى الحافظة\u{001F}محرر الشيفرة\u{001F}تنفيذ\u{001F}الإصدار الأول\u{001F}أحدث إصدار\u{001F}إظهار بالكامل\u{001F}تصغير\u{001F}الإصدار التالي\u{001F}الإصدار السابق\u{001F}إعادة تعيين الإدخال\u{001F}قيد التشغيل\u{001F}إرسال إلى الطرفية\u{001F}طرفية\u{001F}إخفاء تعليقات الفيديو والصورة الرمزية\u{001F}تعديل طبقة الصوت\u{001F}الطبقة\u{001F}تعديل سرعة التشغيل\u{001F}السرعة\u{001F}التعليقات\u{001F}عدم الاعتماد على الألوان وحدها\u{001F}فتح المحرر\u{001F}معلومات\u{001F}الإعدادات\u{001F}مشاركة\u{001F}شارك عبر ...\u{001F}تلميحات\u{001F}الترجمات\u{001F}الدخول إلى وضع ملء الشاشة\u{001F}الخروج من وضع ملء الشاشة\u{001F}الرئيسية\u{001F}المؤلف: \u{001F}المؤلفون: \u{001F}التاريخ: \u{001F}البريد الإلكتروني: \u{001F}تنزيل الوسائط للاستخدام دون اتصال\u{001F}فشل\u{001F}الوسائط دون اتصال\u{001F}الإصدار: \u{001F}وضع العرض\u{001F}إخفاء التنقل\u{001F}العرض\u{001F}الشرائح\u{001F}الكتاب المدرسي\u{001F}لا توجد ترجمة حتى الآن\u{001F}رمز الاستجابة السريعة للموقع\u{001F}تكبير رمز الاستجابة السريعة\u{001F}خطأ أثناء الترميز إلى رمز الاستجابة السريعة\u{001F}لم يتم إعطاء الإجابة الصحيحة بعد\u{001F}إجابة تم حلها\u{001F}مبروك، هذه كانت الإجابة الصحيحة\u{001F}تحقق\u{001F}اضغط Enter على منطقة إفلات لتحديدها، ثم Enter على بطاقة لوضعها فيها\u{001F}منطقة الإفلات\u{001F}فارغة\u{001F}فراغ\u{001F}إظهار تلميح\u{001F}الإجابة\u{001F}تحقق من الإجابة. سيتم وضع علامة على الإجابة بأنها صحيحة أو غير صحيحة.\u{001F}اعرض الحل. سيتم وضع علامة على الاختبار بأنه محلول.\u{001F}اختيار\u{001F}إظهار الحل\u{001F}ترتيب تصاعدي\u{001F}ترتيب تنازلي\u{001F}غير مرتب\u{001F}الصوت معطل\u{001F}الصوت مفعل\u{001F}يجب الإجابة عن السؤال قبل الإرسال.\u{001F}يجب الإجابة عن كل صف قبل الإرسال.\u{001F}إرسال\u{001F}شكرًا على ملاحظاتك!\u{001F}أدخل نصًا...\u{001F}تحديث\u{001F}ترجمة من جوجل (تجريبي)\u{001F}من\u{001F}إيقاف مؤقت\u{001F}موضع التشغيل\u{001F}تفضيل تحويل النص إلى كلام في المتصفح\u{001F}استئناف\u{001F}متصفحك لا يدعم تحويل النص إلى كلام، جرّب متصفحًا آخر.\u{001F}يتم استخدام محرك تحويل النص إلى كلام المدمج في المتصفح."


i18nBg : String
i18nBg =
    "Аа\u{001F}Затвори диалога\u{001F}Изчистване на търсенето\u{001F}редакторски стил\u{001F}Размер на шрифта: \u{001E}\u{001F}Бележка под линия\u{001F}Бележки под линия\u{001F}български\u{001F}отваря се в нов раздел\u{001F}Следващ\u{001F}няма резултати\u{001F}един резултат\u{001F}Възпроизвеждане\u{001F}Предишен\u{001F}Преоразмеряване на панелите\u{001F}Резултати\u{001F}Търсене\u{001F}малък\u{001F}среден\u{001F}голям\u{001F}Пропусни навигацията\u{001F}Слайд\u{001F}Навигация по слайдовете\u{001F}Стъпка\u{001F}Спиране\u{001F}Съдържание\u{001F}Увеличи\u{001F}Синьо\u{001F}светъл режим\u{001F}Цвят\u{001F}тъмен режим\u{001F}По подразбиране\u{001F}Червено\u{001F}Цветова схема\u{001F}Тюркоазено\u{001F}Жълто\u{001F}Стълбовидна диаграма\u{001F}Диаграма „кутия с мустаци“\u{001F}Диаграма\u{001F}Фунийна диаграма\u{001F}Граф на връзките\u{001F}Топлинна карта\u{001F}Линейна диаграма\u{001F}Линейна графика\u{001F}Карта\u{001F}Диаграма с паралелни координати\u{001F}Кръгова диаграма\u{001F}Радарна диаграма\u{001F}Диаграма на Санки\u{001F}Точкова диаграма\u{001F}Таблица\u{001F}Облак от думи\u{001F}Затвори чат\u{001F}Съобщение в чата\u{001F}Имате непрочетени чат съобщения\u{001F}Отвори чат\u{001F}Изпрати съобщение\u{001F}Непотвърден подател\u{001F}Блок с код\u{001F}Копирано в клипборда\u{001F}Копирай в клипборда\u{001F}Редактор на код\u{001F}Изпълни\u{001F}Първа версия\u{001F}Последна версия\u{001F}Максимизиране\u{001F}Минимизиране\u{001F}следваща версия\u{001F}Предишна версия\u{001F}нулиране на въведеното\u{001F}се изпълнява\u{001F}Изпрати към терминала\u{001F}терминал\u{001F}Скриване на коментарите с видео и аватар\u{001F}Промяна на тон\u{001F}Тон\u{001F}Промяна на скоростта на възпроизвеждане\u{001F}Скорост\u{001F}Коментари\u{001F}Не разчитайте само на цвета\u{001F}Отвори редактор\u{001F}Информация\u{001F}Настройки\u{001F}Споделяне\u{001F}споделете чрез ...\u{001F}Подсказки\u{001F}Преводи\u{001F}Цял екран\u{001F}Изход от цял екран\u{001F}Начало\u{001F}Автор: \u{001F}Автори: \u{001F}Дата: \u{001F}Имейл: \u{001F}Изтегляне на медиите за офлайн използване\u{001F}неуспешни\u{001F}Медии офлайн\u{001F}Версия: \u{001F}Режим на презентация\u{001F}Скриване на навигацията\u{001F}Презентация\u{001F}Слайдове\u{001F}Учебник\u{001F}Все още няма превод\u{001F}QR код за уебсайт\u{001F}Увеличи QR кода\u{001F}Грешка при кодирането към QR код\u{001F}Все още не е даден правилният отговор\u{001F}Решен отговор\u{001F}Поздравления, това беше правилният отговор\u{001F}Проверка\u{001F}Натиснете Enter върху зона за пускане, за да я изберете, след това Enter върху карта, за да я поставите там\u{001F}Зона за пускане\u{001F}празна\u{001F}Празно място\u{001F}Покажи подсказка\u{001F}Отговор\u{001F}Проверете отговора. Отговорът ще бъде маркиран като правилен или неправилен.\u{001F}Покажете решението. Тестът ще бъде отбелязан като решен.\u{001F}избор\u{001F}Покажи решението\u{001F}сортиране във възходящ ред\u{001F}сортиране в низходящ ред\u{001F}несортирано\u{001F}Звук изкл.\u{001F}Звук вкл.\u{001F}Преди изпращане трябва да се отговори на въпроса.\u{001F}Преди изпращане трябва да се отговори на всеки ред.\u{001F}Изпрати\u{001F}Благодарим за обратната връзка!\u{001F}Въведете текст...\u{001F}Актуализирай\u{001F}Превод с Google (експериментално)\u{001F}от\u{001F}Пауза\u{001F}Позиция на възпроизвеждане\u{001F}Предпочитам TTS на браузъра\u{001F}Продължи\u{001F}Вашият браузър не поддържа синтез на говор, опитайте с друг.\u{001F}Използване на вътрешната машина за синтезиран говор на браузъра."


i18nBn : String
i18nBn =
    "অআ\u{001F}ডায়ালগ বন্ধ করুন\u{001F}অনুসন্ধান মুছে ফেলুন\u{001F}সম্পাদক-স্টাইল\u{001F}ফন্ট সাইজ: \u{001E}\u{001F}পাদটীকা\u{001F}পাদটীকাসমূহ\u{001F}বাংলা\u{001F}নতুন ট্যাবে খোলে\u{001F}পরবর্তী\u{001F}কোন ফলাফল নেই\u{001F}একটি ফলাফল\u{001F}চালান\u{001F}পূর্ববর্তী\u{001F}প্যানেলের আকার পরিবর্তন করুন\u{001F}ফলাফল\u{001F}অনুসন্ধান\u{001F}ছোট\u{001F}মাঝারি\u{001F}বড়\u{001F}নেভিগেশন এড়িয়ে যান\u{001F}স্লাইড\u{001F}স্লাইড নেভিগেশন\u{001F}ধাপ\u{001F}থামান\u{001F}সূচী\u{001F}বড় করুন\u{001F}নীল\u{001F}লাইট মোড\u{001F}রঙ\u{001F}ডার্ক মোড\u{001F}ডিফল্ট\u{001F}লাল\u{001F}রঙের স্কিম\u{001F}টার্কোয়াজ\u{001F}হলুদ\u{001F}বার চার্ট\u{001F}বক্স প্লট\u{001F}চার্ট\u{001F}ফানেল চার্ট\u{001F}সম্পর্ক গ্রাফ\u{001F}হিটম্যাপ\u{001F}লাইন চার্ট\u{001F}লাইন গ্রাফ\u{001F}ম্যাপ\u{001F}প্যারালেল কোঅর্ডিনেট ম্যাপ\u{001F}পাই চার্ট\u{001F}রেডার চার্ট\u{001F}স্যাঙ্কি ডায়াগ্রাম\u{001F}স্ক্যাটার প্লট\u{001F}টেবিল\u{001F}ওয়ার্ড ক্লাউড\u{001F}চ্যাট বন্ধ করুন\u{001F}চ্যাট বার্তা\u{001F}আপনার অপঠিত চ্যাট বার্তা আছে\u{001F}চ্যাট খুলুন\u{001F}বার্তা পাঠান\u{001F}অযাচাইকৃত প্রেরক\u{001F}কোড ব্লক\u{001F}ক্লিপবোর্ডে কপি করা হয়েছে\u{001F}ক্লিপবোর্ডে কপি করুন\u{001F}কোড এডিটর\u{001F}চালান\u{001F}প্রথম সংস্করণ\u{001F}শেষ সংস্করণ\u{001F}দৃশ্য বড় করুন\u{001F}দৃশ্য ছোট করুন\u{001F}পরবর্তী সংস্করণ\u{001F}পূর্ববর্তী সংস্করণ\u{001F}ইনপুট রিসেট করুন\u{001F}চলছে\u{001F}টার্মিনালে পাঠান\u{001F}টার্মিনাল\u{001F}ভিডিও ও অবতার মন্তব্য লুকান\u{001F}স্বরের উচ্চতা সামঞ্জস্য করুন\u{001F}স্বর\u{001F}প্লেব্যাকের গতি সামঞ্জস্য করুন\u{001F}গতি\u{001F}মন্তব্য\u{001F}শুধু রঙের উপর নির্ভর করবেন না\u{001F}সম্পাদক খুলুন\u{001F}তথ্য\u{001F}সেটিংস\u{001F}ভাগ করুন\u{001F}এর মাধ্যমে ভাগ করুন ...\u{001F}টুলটিপ\u{001F}অনুবাদ\u{001F}ফুলস্ক্রিনে ঢুকুন\u{001F}ফুলস্ক্রিন থেকে বের হোন\u{001F}হোম\u{001F}লেখক: \u{001F}লেখকবৃন্দ: \u{001F}তারিখ: \u{001F}ইমেইল: \u{001F}অফলাইনে ব্যবহারের জন্য মিডিয়া ডাউনলোড করুন\u{001F}ব্যর্থ\u{001F}মিডিয়া অফলাইন\u{001F}সংস্করণ: \u{001F}প্রেজেন্টেশন মোড\u{001F}নেভিগেশন লুকান\u{001F}প্রেজেন্টেশন\u{001F}স্লাইড\u{001F}পাঠ্যবই\u{001F}এখনও অনুবাদ নেই\u{001F}ওয়েবসাইটের জন্য QR কোড\u{001F}QR কোড বড় করুন\u{001F}QR কোডে এনকোডিং সমস্যা হয়েছে\u{001F}সঠিক উত্তরটি এখনও দেওয়া হয়নি\u{001F}সমাধানকৃত উত্তর\u{001F}অভিনন্দন, সেটা সঠিক উত্তর ছিল\u{001F}পরীক্ষা করুন\u{001F}একটি ড্রপ জোন নির্বাচন করতে তাতে Enter চাপুন, তারপর একটি কার্ড সেখানে রাখতে কার্ডটিতে Enter চাপুন\u{001F}ড্রপ জোন\u{001F}খালি\u{001F}শূন্যস্থান\u{001F}ইঙ্গিত দেখান\u{001F}উত্তর\u{001F}উত্তরটি পরীক্ষা করুন। প্রতিক্রিয়াটি সঠিক বা ভুল হিসাবে চিহ্নিত করা হবে।\u{001F}সমাধান প্রদর্শন করুন। কুইজটি সমাধানকৃত হিসাবে চিহ্নিত করা হবে।\u{001F}নির্বাচন\u{001F}সমাধান প্রদর্শন করুন\u{001F}আরোহী ক্রমানুসারে সাজান\u{001F}অবরোহী ক্রমানুসারে সাজান\u{001F}সাজানো নয়\u{001F}শব্দ বন্ধ\u{001F}শব্দ চালু\u{001F}জমা দেওয়ার আগে প্রশ্নটির উত্তর দিতে হবে।\u{001F}জমা দেওয়ার আগে প্রতিটি সারির উত্তর দিতে হবে।\u{001F}জমা দিন\u{001F}আপনার মতামতের জন্য ধন্যবাদ!\u{001F}কিছু লিখুন...\u{001F}হালনাগাদ করুন\u{001F}Google দিয়ে অনুবাদ করুন (পরীক্ষামূলক)\u{001F}/\u{001F}বিরতি\u{001F}প্লেব্যাকের অবস্থান\u{001F}ব্রাউজার TTS পছন্দ করুন\u{001F}চালিয়ে যান\u{001F}আপনার ব্রাউজার টেক্সট-টু-স্পিচ সমর্থন করে না, অন্য কোন ব্রাউজার চেষ্টা করুন।\u{001F}ব্রাউজারের অভ্যন্তরীণ টেক্সট-টু-স্পিচ ইঞ্জিন ব্যবহার করা হচ্ছে।"


i18nCa : String
i18nCa =
    "Aa\u{001F}Tanca el diàleg\u{001F}esborra la cerca\u{001F}Estil de l'editor\u{001F}mida de la lletra: \u{001E}\u{001F}Nota al peu\u{001F}Notes al peu\u{001F}Català\u{001F}s'obre en una pestanya nova\u{001F}següent\u{001F}cap resultat\u{001F}un resultat\u{001F}reprodueix\u{001F}anterior\u{001F}Redimensiona els panells\u{001F}resultats\u{001F}Cerca\u{001F}petita\u{001F}mitjana\u{001F}gran\u{001F}Salta la navegació\u{001F}Diapositiva\u{001F}Navegació per les diapositives\u{001F}Pas\u{001F}atura\u{001F}Taula de continguts\u{001F}Amplia\u{001F}Blau\u{001F}Mode clar\u{001F}Color\u{001F}Mode fosc\u{001F}Per defecte\u{001F}Vermell\u{001F}Esquema de colors\u{001F}Turquesa\u{001F}Groc\u{001F}Gràfic de barres\u{001F}Diagrama de caixa\u{001F}Gràfic\u{001F}Gràfic d'embut\u{001F}Graf de relacions\u{001F}Mapa de calor\u{001F}Gràfic de línies\u{001F}Gràfic lineal\u{001F}Mapa\u{001F}Gràfic de coordenades paral·leles\u{001F}Gràfic de sectors\u{001F}Gràfic de radar\u{001F}Diagrama de Sankey\u{001F}Diagrama de dispersió\u{001F}Taula\u{001F}Núvol de paraules\u{001F}Tanca el xat\u{001F}Missatge de xat\u{001F}Tens missatges de xat sense llegir\u{001F}Obre el xat\u{001F}Envia un missatge\u{001F}Remitent no verificat\u{001F}Bloc de codi\u{001F}copiat al porta-retalls\u{001F}copia al porta-retalls\u{001F}Editor de codi\u{001F}Executa\u{001F}primera versió\u{001F}última versió\u{001F}maximitza la vista\u{001F}minimitza la vista\u{001F}versió següent\u{001F}versió anterior\u{001F}restableix l'entrada\u{001F}s'està executant\u{001F}Envia al terminal\u{001F}terminal\u{001F}Amaga els comentaris de vídeo i d'avatar\u{001F}Ajusta el to de la veu\u{001F}To\u{001F}Ajusta la velocitat de reproducció\u{001F}Velocitat\u{001F}Comentaris\u{001F}No dependre només del color\u{001F}Obre l'editor\u{001F}Informació\u{001F}Configuració\u{001F}Comparteix\u{001F}comparteix mitjançant ...\u{001F}Indicadors de funció\u{001F}Traduccions\u{001F}Entra a pantalla completa\u{001F}Surt de pantalla completa\u{001F}Inici\u{001F}Autor: \u{001F}Autors: \u{001F}Data: \u{001F}Correu electrònic: \u{001F}Baixa els mitjans per a ús sense connexió\u{001F}fallits\u{001F}Mitjans sense connexió\u{001F}Versió: \u{001F}Mode de presentació\u{001F}Amaga la navegació\u{001F}Presentació\u{001F}Diapositives\u{001F}Llibre de text\u{001F}encara no hi ha cap traducció\u{001F}Codi QR del lloc web\u{001F}Amplia el codi QR\u{001F}Error en generar el codi QR\u{001F}Encara no s'ha donat la resposta correcta\u{001F}Resposta revelada\u{001F}Enhorabona, aquesta era la resposta correcta\u{001F}Comprova\u{001F}Prem Retorn en una zona per seleccionar-la i després Retorn en una targeta per col·locar-la-hi\u{001F}Zona per deixar anar\u{001F}buida\u{001F}Buit\u{001F}mostra una pista\u{001F}Resposta\u{001F}Comprova la resposta. La resposta es marcarà com a correcta o incorrecta.\u{001F}Mostra la solució. L'exercici es marcarà com a resolt.\u{001F}selecció\u{001F}mostra la solució\u{001F}ordena de manera ascendent\u{001F}ordena de manera descendent\u{001F}sense ordenar\u{001F}So desactivat\u{001F}So activat\u{001F}Cal respondre la pregunta abans de l'enviament.\u{001F}Cal respondre totes les files abans de l'enviament.\u{001F}Envia\u{001F}Gràcies pels teus comentaris!\u{001F}Introdueix un text...\u{001F}Actualitza\u{001F}Tradueix amb Google (experimental)\u{001F}de\u{001F}Pausa\u{001F}Posició de reproducció\u{001F}Prefereix la síntesi de veu del navegador\u{001F}Reprèn\u{001F}El teu navegador no admet la síntesi de veu. Prova'n un altre.\u{001F}S'utilitza el motor de síntesi de veu integrat del navegador."


i18nCs : String
i18nCs =
    "Aa\u{001F}Zavřít dialog\u{001F}vymazat hledání\u{001F}Styl editoru\u{001F}velikost písma: \u{001E}\u{001F}Poznámka pod čarou\u{001F}Poznámky pod čarou\u{001F}Čeština\u{001F}otevře se na nové kartě\u{001F}další\u{001F}žádné výsledky\u{001F}jeden výsledek\u{001F}přehrát\u{001F}předchozí\u{001F}Změnit velikost panelů\u{001F}výsledky\u{001F}Hledat\u{001F}malá\u{001F}střední\u{001F}velká\u{001F}Přeskočit navigaci\u{001F}Snímek\u{001F}Navigace mezi snímky\u{001F}Krok\u{001F}zastavit\u{001F}Obsah\u{001F}Zvětšit\u{001F}Modrá\u{001F}Světlý režim\u{001F}Barva\u{001F}Tmavý režim\u{001F}Výchozí\u{001F}Červená\u{001F}Barevné schéma\u{001F}Tyrkysová\u{001F}Žlutá\u{001F}Sloupcový graf\u{001F}Krabicový graf\u{001F}Graf\u{001F}Trychtýřový graf\u{001F}Graf vztahů\u{001F}Tepelná mapa\u{001F}Spojnicový graf\u{001F}Čárový graf\u{001F}Mapa\u{001F}Graf paralelních souřadnic\u{001F}Výsečový graf\u{001F}Paprskový graf\u{001F}Sankeyův diagram\u{001F}Bodový graf\u{001F}Tabulka\u{001F}Slovní mrak\u{001F}Zavřít chat\u{001F}Zpráva do chatu\u{001F}Máš nepřečtené zprávy v chatu\u{001F}Otevřít chat\u{001F}Odeslat zprávu\u{001F}Neověřený odesílatel\u{001F}Blok kódu\u{001F}zkopírováno do schránky\u{001F}zkopírovat do schránky\u{001F}Editor kódu\u{001F}Spustit\u{001F}první verze\u{001F}poslední verze\u{001F}maximalizovat zobrazení\u{001F}minimalizovat zobrazení\u{001F}další verze\u{001F}předchozí verze\u{001F}obnovit vstup\u{001F}běží\u{001F}Odeslat do terminálu\u{001F}terminál\u{001F}Skrýt komentáře videa a avatara\u{001F}Upravit výšku hlasu\u{001F}Výška\u{001F}Upravit rychlost přehrávání\u{001F}Rychlost\u{001F}Komentáře\u{001F}Nespoléhat jen na barvy\u{001F}Otevřít editor\u{001F}Informace\u{001F}Nastavení\u{001F}Sdílet\u{001F}sdílet přes ...\u{001F}Popisky\u{001F}Překlady\u{001F}Přejít na celou obrazovku\u{001F}Ukončit režim celé obrazovky\u{001F}Domů\u{001F}Autor: \u{001F}Autoři: \u{001F}Datum: \u{001F}E-mail: \u{001F}Stáhnout média pro použití offline\u{001F}selhalo\u{001F}Média offline\u{001F}Verze: \u{001F}Režim prezentace\u{001F}Skrýt navigaci\u{001F}Prezentace\u{001F}Snímky\u{001F}Učebnice\u{001F}překlad zatím není k dispozici\u{001F}QR kód webové stránky\u{001F}Zvětšit QR kód\u{001F}Chyba při vytváření QR kódu\u{001F}Správná odpověď ještě nebyla zadána\u{001F}Odhalená odpověď\u{001F}Gratulujeme, to byla správná odpověď\u{001F}Zkontrolovat\u{001F}Klávesou Enter vyber cílové pole, pak klávesou Enter na kartě ji do něj umísti\u{001F}Cílové pole\u{001F}prázdné\u{001F}Mezera\u{001F}zobrazit nápovědu\u{001F}Odpověď\u{001F}Zkontrolovat odpověď. Odpověď bude označena jako správná nebo nesprávná.\u{001F}Zobrazit řešení. Úloha bude označena jako vyřešená.\u{001F}výběr\u{001F}zobrazit řešení\u{001F}řadit vzestupně\u{001F}řadit sestupně\u{001F}neseřazeno\u{001F}Zvuk vypnut\u{001F}Zvuk zapnut\u{001F}Před odesláním je nutné odpovědět na otázku.\u{001F}Před odesláním je nutné odpovědět v každém řádku.\u{001F}Odeslat\u{001F}Děkujeme za zpětnou vazbu!\u{001F}Zadej text...\u{001F}Aktualizovat\u{001F}Přeložit pomocí Googlu (experimentální)\u{001F}z\u{001F}Pozastavit\u{001F}Pozice přehrávání\u{001F}Upřednostnit syntézu řeči prohlížeče\u{001F}Pokračovat\u{001F}Tvůj prohlížeč nepodporuje syntézu řeči. Zkus jiný.\u{001F}Používá se vestavěná syntéza řeči prohlížeče."


i18nDa : String
i18nDa =
    "Aa\u{001F}Luk dialogboks\u{001F}ryd søgning\u{001F}Editorstil\u{001F}skriftstørrelse: \u{001E}\u{001F}Fodnote\u{001F}Fodnoter\u{001F}Dansk\u{001F}åbner i en ny fane\u{001F}næste\u{001F}ingen resultater\u{001F}ét resultat\u{001F}afspil\u{001F}forrige\u{001F}Tilpas panelernes størrelse\u{001F}resultater\u{001F}Søg\u{001F}lille\u{001F}mellem\u{001F}stor\u{001F}Spring navigation over\u{001F}Dias\u{001F}Diasnavigation\u{001F}Trin\u{001F}stop\u{001F}Indholdsfortegnelse\u{001F}Forstør\u{001F}Blå\u{001F}Lys tilstand\u{001F}Farve\u{001F}Mørk tilstand\u{001F}Standard\u{001F}Rød\u{001F}Farveskema\u{001F}Turkis\u{001F}Gul\u{001F}Søjlediagram\u{001F}Boksplot\u{001F}Diagram\u{001F}Tragtdiagram\u{001F}Relationsgraf\u{001F}Varmekort\u{001F}Linjediagram\u{001F}Linjegraf\u{001F}Kort\u{001F}Diagram med parallelle koordinater\u{001F}Cirkeldiagram\u{001F}Radardiagram\u{001F}Sankey-diagram\u{001F}Punktdiagram\u{001F}Tabel\u{001F}Ordsky\u{001F}Luk chatten\u{001F}Chatbesked\u{001F}Du har ulæste chatbeskeder\u{001F}Åbn chatten\u{001F}Send besked\u{001F}Ubekræftet afsender\u{001F}Kodeblok\u{001F}kopieret til udklipsholder\u{001F}kopiér til udklipsholder\u{001F}Kodeeditor\u{001F}Kør\u{001F}første version\u{001F}seneste version\u{001F}maksimer visning\u{001F}minimer visning\u{001F}næste version\u{001F}forrige version\u{001F}nulstil input\u{001F}kører\u{001F}Send til terminal\u{001F}terminal\u{001F}Skjul video- og avatarkommentarer\u{001F}Juster tonehøjde\u{001F}Tonehøjde\u{001F}Juster afspilningshastighed\u{001F}Tempo\u{001F}Kommentarer\u{001F}Brug ikke kun farver\u{001F}Åbn editoren\u{001F}Information\u{001F}Indstillinger\u{001F}Del\u{001F}del via ...\u{001F}Værktøjstip\u{001F}Oversættelser\u{001F}Aktivér fuld skærm\u{001F}Afslut fuld skærm\u{001F}Hjem\u{001F}Forfatter: \u{001F}Forfattere: \u{001F}Dato: \u{001F}E-mail: \u{001F}Download medier til offlinebrug\u{001F}mislykkedes\u{001F}Medier offline\u{001F}Version: \u{001F}Præsentationstilstand\u{001F}Skjul navigation\u{001F}Præsentation\u{001F}Dias\u{001F}Lærebog\u{001F}endnu ingen oversættelse\u{001F}QR-kode til webstedet\u{001F}Forstør QR-kode\u{001F}Fejl ved oprettelse af QR-kode\u{001F}Det rigtige svar er endnu ikke angivet\u{001F}Afsløret svar\u{001F}Tillykke, det var det rigtige svar\u{001F}Kontrollér\u{001F}Tryk Enter på et slipfelt for at vælge det, og derefter Enter på et kort for at placere det der\u{001F}Slipfelt\u{001F}tomt\u{001F}Hul\u{001F}vis tip\u{001F}Svar\u{001F}Kontrollér svaret. Svaret markeres som rigtigt eller forkert.\u{001F}Vis løsningen. Opgaven markeres som løst.\u{001F}valg\u{001F}vis løsning\u{001F}sortér stigende\u{001F}sortér faldende\u{001F}ikke sorteret\u{001F}Lyd fra\u{001F}Lyd til\u{001F}Spørgsmålet skal besvares inden afsendelse.\u{001F}Alle rækker skal besvares inden afsendelse.\u{001F}Send\u{001F}Tak for din feedback!\u{001F}Indtast en tekst...\u{001F}Opdater\u{001F}Oversæt med Google (eksperimentelt)\u{001F}af\u{001F}Pause\u{001F}Afspilningsposition\u{001F}Foretræk browserens talesyntese\u{001F}Genoptag\u{001F}Din browser understøtter ikke talesyntese. Prøv en anden.\u{001F}Browserens indbyggede talesyntese bruges."


i18nDe : String
i18nDe =
    "Aa\u{001F}Dialog schließen\u{001F}Suche löschen\u{001F}Editor-Stil\u{001F}Schriftgröße: \u{001E}\u{001F}Fußnote\u{001F}Fußnoten\u{001F}Deutsch\u{001F}öffnet in neuem Tab\u{001F}weiter\u{001F}kein Ergebnis\u{001F}ein Ergebnis\u{001F}Wiedergabe\u{001F}zurück\u{001F}Größe der Bereiche ändern\u{001F}Ergebnisse\u{001F}Suche\u{001F}klein\u{001F}mittel\u{001F}groß\u{001F}Navigation überspringen\u{001F}Folie\u{001F}Folien-Navigation\u{001F}Schritt\u{001F}Stopp\u{001F}Inhaltsverzeichnis\u{001F}Vergrößern\u{001F}Blau\u{001F}Hellmodus\u{001F}Farbe\u{001F}Dunkelmodus\u{001F}Standard\u{001F}Rot\u{001F}Farbschema\u{001F}Türkis\u{001F}Gelb\u{001F}Balkendiagramm\u{001F}Boxplot\u{001F}Diagramm\u{001F}Trichterdiagramm\u{001F}Beziehungsgrafik\u{001F}Heatmap\u{001F}Liniendiagramm\u{001F}Liniendiagramm\u{001F}Karte\u{001F}Parallele Koordinatenkarte\u{001F}Tortendiagramm\u{001F}Radar-Karte\u{001F}Sankey-Diagramm\u{001F}Streudiagramm\u{001F}Tabelle\u{001F}Wortwolke\u{001F}Chat schließen\u{001F}Chat-Nachricht\u{001F}Du hast ungelesene Chat-Nachrichten\u{001F}Chat öffnen\u{001F}Nachricht senden\u{001F}Unbestätigter Absender\u{001F}Codeblock\u{001F}in die Zwischenablage kopiert\u{001F}in die Zwischenablage kopieren\u{001F}Code-Editor\u{001F}Ausführen\u{001F}erste Version\u{001F}letzte Version\u{001F}Darstellung maximieren\u{001F}Darstellung minimieren\u{001F}eine Version vor\u{001F}eine Version zurück\u{001F}Eingabe zurücksetzen\u{001F}wird ausgeführt\u{001F}An das Terminal senden\u{001F}Terminal\u{001F}Video- & Avatar-Kommentare ausblenden\u{001F}Anpassung der Tonhöhe\u{001F}Tonhöhe\u{001F}Anpassung der Abspielgeschwindigkeit\u{001F}Tempo\u{001F}Kommentare\u{001F}Nicht nur Farben verwenden\u{001F}Editor öffnen\u{001F}Informationen\u{001F}Einstellungen\u{001F}Teilen\u{001F}Teilen per ...\u{001F}Tooltipps\u{001F}Übersetzungen\u{001F}Vollbildmodus aktivieren\u{001F}Vollbildmodus beenden\u{001F}Übersicht\u{001F}Autor: \u{001F}Autoren: \u{001F}Datum: \u{001F}E-Mail: \u{001F}Medien für offline herunterladen\u{001F}fehlgeschlagen\u{001F}Medien offline\u{001F}Version: \u{001F}Präsentationsmodus\u{001F}Navigation ausblenden\u{001F}Präsentation\u{001F}Folien\u{001F}Lehrbuch\u{001F}noch keine Übersetzungen vorhanden\u{001F}QR-Code für Webseite\u{001F}QR-Code vergrößern\u{001F}Fehler beim Codieren in QR-Code\u{001F}Die richtige Antwort wurde noch nicht gegeben\u{001F}Aufgelöste Antwort\u{001F}Herzlichen Glückwunsch, das war die richtige Antwort\u{001F}Prüfen\u{001F}Mit Enter ein Ablagefeld wählen, dann mit Enter eine Karte darauf ablegen\u{001F}Ablagefeld\u{001F}leer\u{001F}Lücke\u{001F}Hinweis anzeigen\u{001F}Antwort\u{001F}Überprüfe die Antwort. Die Antwort wird als richtig oder falsch markiert.\u{001F}Zeige die Lösung. Das Quiz wird als aufgelöst markiert.\u{001F}Auswahl\u{001F}zeige Lösung\u{001F}aufsteigend sortieren\u{001F}absteigend sortieren\u{001F}nicht sortiert\u{001F}Sprecher aus\u{001F}Sprecher an\u{001F}Die Frage muss vor dem Absenden beantwortet werden.\u{001F}Vor dem Absenden muss jede Zeile beantwortet werden.\u{001F}Abschicken\u{001F}Vielen Dank für dein Feedback!\u{001F}Texteingabe ...\u{001F}Aktualisieren\u{001F}Mit Google übersetzen (experimentell)\u{001F}von\u{001F}Pausieren\u{001F}Wiedergabeposition\u{001F}Browser-TTS bevorzugen\u{001F}Fortsetzen\u{001F}Ihr Browser unterstützt kein Text-to-Speech, versuchen Sie es mit einem anderen.\u{001F}Verwendung der internen Text-zu-Speech-Engine des Browsers."


i18nEl : String
i18nEl =
    "Aa\u{001F}Κλείσιμο διαλόγου\u{001F}εκκαθάριση αναζήτησης\u{001F}Στυλ επεξεργαστή\u{001F}μέγεθος γραμματοσειράς: \u{001E}\u{001F}Υποσημείωση\u{001F}Υποσημειώσεις\u{001F}Ελληνικά\u{001F}ανοίγει σε νέα καρτέλα\u{001F}επόμενο\u{001F}κανένα αποτέλεσμα\u{001F}ένα αποτέλεσμα\u{001F}αναπαραγωγή\u{001F}προηγούμενο\u{001F}Αλλαγή μεγέθους περιοχών\u{001F}αποτελέσματα\u{001F}Αναζήτηση\u{001F}μικρό\u{001F}μεσαίο\u{001F}μεγάλο\u{001F}Παράλειψη πλοήγησης\u{001F}Διαφάνεια\u{001F}Πλοήγηση διαφανειών\u{001F}Βήμα\u{001F}διακοπή\u{001F}Πίνακας περιεχομένων\u{001F}Μεγέθυνση\u{001F}Μπλε\u{001F}Φωτεινή λειτουργία\u{001F}Χρώμα\u{001F}Σκοτεινή λειτουργία\u{001F}Προεπιλογή\u{001F}Κόκκινο\u{001F}Συνδυασμός χρωμάτων\u{001F}Τιρκουάζ\u{001F}Κίτρινο\u{001F}Ραβδόγραμμα\u{001F}Θηκόγραμμα\u{001F}Διάγραμμα\u{001F}Διάγραμμα χοάνης\u{001F}Γράφος σχέσεων\u{001F}Θερμικός χάρτης\u{001F}Γραμμικό διάγραμμα\u{001F}Γραμμικό γράφημα\u{001F}Χάρτης\u{001F}Διάγραμμα παράλληλων συντεταγμένων\u{001F}Κυκλικό διάγραμμα\u{001F}Διάγραμμα ραντάρ\u{001F}Διάγραμμα Sankey\u{001F}Διάγραμμα διασποράς\u{001F}Πίνακας\u{001F}Σύννεφο λέξεων\u{001F}Κλείσιμο συνομιλίας\u{001F}Μήνυμα συνομιλίας\u{001F}Έχεις μη αναγνωσμένα μηνύματα συνομιλίας\u{001F}Άνοιγμα συνομιλίας\u{001F}Αποστολή μηνύματος\u{001F}Μη επαληθευμένος αποστολέας\u{001F}Μπλοκ κώδικα\u{001F}αντιγράφηκε στο πρόχειρο\u{001F}αντιγραφή στο πρόχειρο\u{001F}Επεξεργαστής κώδικα\u{001F}Εκτέλεση\u{001F}πρώτη έκδοση\u{001F}τελευταία έκδοση\u{001F}μεγιστοποίηση προβολής\u{001F}ελαχιστοποίηση προβολής\u{001F}επόμενη έκδοση\u{001F}προηγούμενη έκδοση\u{001F}επαναφορά εισόδου\u{001F}εκτελείται\u{001F}Αποστολή στο τερματικό\u{001F}τερματικό\u{001F}Απόκρυψη σχολίων βίντεο και άβαταρ\u{001F}Προσαρμογή ύψους φωνής\u{001F}Τόνος\u{001F}Προσαρμογή ταχύτητας αναπαραγωγής\u{001F}Ταχύτητα\u{001F}Σχόλια\u{001F}Όχι μόνο με χρώματα\u{001F}Άνοιγμα επεξεργαστή\u{001F}Πληροφορίες\u{001F}Ρυθμίσεις\u{001F}Κοινοποίηση\u{001F}κοινοποίηση μέσω ...\u{001F}Συμβουλές εργαλείων\u{001F}Μεταφράσεις\u{001F}Είσοδος σε πλήρη οθόνη\u{001F}Έξοδος από πλήρη οθόνη\u{001F}Αρχική\u{001F}Συγγραφέας: \u{001F}Συγγραφείς: \u{001F}Ημερομηνία: \u{001F}Email: \u{001F}Λήψη πολυμέσων για χρήση εκτός σύνδεσης\u{001F}απέτυχαν\u{001F}Πολυμέσα εκτός σύνδεσης\u{001F}Έκδοση: \u{001F}Λειτουργία παρουσίασης\u{001F}Απόκρυψη πλοήγησης\u{001F}Παρουσίαση\u{001F}Διαφάνειες\u{001F}Εγχειρίδιο\u{001F}δεν υπάρχει ακόμη μετάφραση\u{001F}Κωδικός QR για τον ιστότοπο\u{001F}Μεγέθυνση κωδικού QR\u{001F}Σφάλμα κατά τη δημιουργία κωδικού QR\u{001F}Δεν έχει δοθεί ακόμη η σωστή απάντηση\u{001F}Απάντηση που αποκαλύφθηκε\u{001F}Συγχαρητήρια, αυτή ήταν η σωστή απάντηση\u{001F}Έλεγχος\u{001F}Πάτησε Enter σε μια περιοχή απόθεσης για να την επιλέξεις και μετά Enter σε μια κάρτα για να την τοποθετήσεις εκεί\u{001F}Περιοχή απόθεσης\u{001F}κενή\u{001F}Κενό\u{001F}εμφάνιση υπόδειξης\u{001F}Απάντηση\u{001F}Έλεγχος της απάντησης. Η απάντηση θα επισημανθεί ως σωστή ή λανθασμένη.\u{001F}Εμφάνιση της λύσης. Η άσκηση θα επισημανθεί ως λυμένη.\u{001F}επιλογή\u{001F}εμφάνιση λύσης\u{001F}αύξουσα ταξινόμηση\u{001F}φθίνουσα ταξινόμηση\u{001F}χωρίς ταξινόμηση\u{001F}Απενεργοποίηση ήχου\u{001F}Ενεργοποίηση ήχου\u{001F}Η ερώτηση πρέπει να απαντηθεί πριν από την υποβολή.\u{001F}Κάθε γραμμή πρέπει να απαντηθεί πριν από την υποβολή.\u{001F}Υποβολή\u{001F}Ευχαριστούμε για τα σχόλιά σου!\u{001F}Πληκτρολόγησε ένα κείμενο...\u{001F}Ενημέρωση\u{001F}Μετάφραση με το Google (πειραματικό)\u{001F}από\u{001F}Παύση\u{001F}Θέση αναπαραγωγής\u{001F}Προτίμηση σύνθεσης ομιλίας του προγράμματος περιήγησης\u{001F}Συνέχεια\u{001F}Το πρόγραμμα περιήγησής σου δεν υποστηρίζει σύνθεση ομιλίας. Δοκίμασε κάποιο άλλο.\u{001F}Χρησιμοποιείται η ενσωματωμένη μηχανή σύνθεσης ομιλίας του προγράμματος περιήγησης."


i18nEs : String
i18nEs =
    "Aa\u{001F}Cerrar diálogo\u{001F}eliminar búsqueda\u{001F}estilo editor\u{001F}Tamaño de fuente: \u{001E}\u{001F}Nota al pie\u{001F}Notas al pie\u{001F}Español\u{001F}se abre en una pestaña nueva\u{001F}siguiente\u{001F}No hay resultados\u{001F}un resultado\u{001F}reproducir\u{001F}anterior\u{001F}Cambiar el tamaño de los paneles\u{001F}Resultados\u{001F}buscar\u{001F}pequeño\u{001F}mediano\u{001F}grande\u{001F}Saltar navegación\u{001F}Diapositiva\u{001F}Navegación de diapositivas\u{001F}Paso\u{001F}parar\u{001F}índice\u{001F}Ampliar\u{001F}azul\u{001F}modo claro\u{001F}color\u{001F}modo oscuro\u{001F}predeterminado\u{001F}rojo\u{001F}Esquema de colores\u{001F}turquesa\u{001F}amarillo\u{001F}Gráfico de barras\u{001F}Diagrama de caja\u{001F}Gráfico\u{001F}Gráfico de embudo\u{001F}Grafo de relaciones\u{001F}Mapa de calor\u{001F}Gráfico de líneas\u{001F}Gráfico lineal\u{001F}Mapa\u{001F}Gráfico de coordenadas paralelas\u{001F}Gráfico circular\u{001F}Gráfico de radar\u{001F}Diagrama de Sankey\u{001F}Diagrama de dispersión\u{001F}Tabla\u{001F}Nube de palabras\u{001F}Cerrar chat\u{001F}Mensaje de chat\u{001F}Tienes mensajes de chat no leídos\u{001F}Abrir chat\u{001F}Enviar mensaje\u{001F}Remitente no verificado\u{001F}Bloque de código\u{001F}copiado al portapapeles\u{001F}copiar al portapapeles\u{001F}Editor de código\u{001F}ejecutar\u{001F}primera versión\u{001F}última versión\u{001F}maximizar vista\u{001F}minimizar vista\u{001F}versión siguiente\u{001F}versión anterior\u{001F}restablecer entrada\u{001F}en funcionamiento\u{001F}Enviar al terminal\u{001F}terminal\u{001F}Ocultar los comentarios de video y avatar\u{001F}ajustar tono\u{001F}Tono\u{001F}ajustar velocidad de reproducción\u{001F}Velocidad\u{001F}Comentarios\u{001F}No depender solo del color\u{001F}Abrir editor\u{001F}información\u{001F}configuración\u{001F}compartir\u{001F}compartir vía ...\u{001F}Descripciones emergentes\u{001F}traducciones\u{001F}entrar en pantalla completa\u{001F}salir de pantalla completa\u{001F}Inicio\u{001F}Autor: \u{001F}Autores: \u{001F}Fecha: \u{001F}Correo electrónico: \u{001F}Descargar multimedia para usar sin conexión\u{001F}fallidos\u{001F}Multimedia sin conexión\u{001F}Versión: \u{001F}Modo presentación\u{001F}Ocultar navegación\u{001F}Presentación\u{001F}Diapositivas\u{001F}Manual\u{001F}aún sin traducción\u{001F}Código QR para sitio web\u{001F}Ampliar código QR\u{001F}Error al codificar en código QR\u{001F}La respuesta correcta aún no ha sido dada\u{001F}Respuesta resuelta\u{001F}Felicitaciones, esa fue la respuesta correcta\u{001F}verificar\u{001F}Pulsa Enter en una zona de destino para seleccionarla y luego Enter en una tarjeta para colocarla allí\u{001F}Zona de destino\u{001F}vacía\u{001F}Hueco\u{001F}mostrar pista\u{001F}Respuesta\u{001F}Comprueba la respuesta. Se marcará como correcta o incorrecta.\u{001F}Muestra la solución. El cuestionario se marcará como resuelto.\u{001F}selección\u{001F}mostrar solución\u{001F}orden ascendente\u{001F}orden descendente\u{001F}no ordenado\u{001F}Sonido apagado\u{001F}Sonido encendido\u{001F}La pregunta debe responderse antes del envío.\u{001F}Todas las filas deben responderse antes del envío.\u{001F}enviar\u{001F}¡Gracias por tus comentarios!\u{001F}introducir texto\u{001F}Actualizar\u{001F}Traducir con Google (experimental)\u{001F}de\u{001F}Pausar\u{001F}Posición de reproducción\u{001F}Preferir TTS del navegador\u{001F}Reanudar\u{001F}Tu navegador no es compatible con la conversión de texto a voz, prueba con otro.\u{001F}Usando el motor interno de conversión de texto a voz del navegador."


i18nEt : String
i18nEt =
    "Aa\u{001F}Sulge dialoog\u{001F}tühjenda otsing\u{001F}Redaktori stiil\u{001F}kirjasuurus: \u{001E}\u{001F}Joonealune märkus\u{001F}Joonealused märkused\u{001F}Eesti\u{001F}avaneb uuel vahekaardil\u{001F}järgmine\u{001F}tulemusi pole\u{001F}üks tulemus\u{001F}esita\u{001F}eelmine\u{001F}Muuda paanide suurust\u{001F}tulemused\u{001F}Otsi\u{001F}väike\u{001F}keskmine\u{001F}suur\u{001F}Jäta navigeerimine vahele\u{001F}Slaid\u{001F}Slaidide navigeerimine\u{001F}Samm\u{001F}peata\u{001F}Sisukord\u{001F}Suurenda\u{001F}Sinine\u{001F}Hele režiim\u{001F}Värv\u{001F}Tume režiim\u{001F}Vaikimisi\u{001F}Punane\u{001F}Värviskeem\u{001F}Türkiissinine\u{001F}Kollane\u{001F}Tulpdiagramm\u{001F}Karpdiagramm\u{001F}Diagramm\u{001F}Lehterdiagramm\u{001F}Seoste graaf\u{001F}Soojuskaart\u{001F}Joondiagramm\u{001F}Joongraafik\u{001F}Kaart\u{001F}Paralleelkoordinaatide diagramm\u{001F}Sektordiagramm\u{001F}Radardiagramm\u{001F}Sankey diagramm\u{001F}Hajuvusdiagramm\u{001F}Tabel\u{001F}Sõnapilv\u{001F}Sulge vestlus\u{001F}Vestlussõnum\u{001F}Sul on lugemata vestlussõnumeid\u{001F}Ava vestlus\u{001F}Saada sõnum\u{001F}Kinnitamata saatja\u{001F}Koodiplokk\u{001F}kopeeritud lõikelauale\u{001F}kopeeri lõikelauale\u{001F}Koodiredaktor\u{001F}Käivita\u{001F}esimene versioon\u{001F}viimane versioon\u{001F}maksimeeri vaade\u{001F}minimeeri vaade\u{001F}järgmine versioon\u{001F}eelmine versioon\u{001F}lähtesta sisend\u{001F}töötab\u{001F}Saada terminali\u{001F}terminal\u{001F}Peida video- ja avatarikommentaarid\u{001F}Muuda hääle kõrgust\u{001F}Kõrgus\u{001F}Muuda taasesituse kiirust\u{001F}Kiirus\u{001F}Kommentaarid\u{001F}Ära tugine ainult värvidele\u{001F}Ava redaktor\u{001F}Teave\u{001F}Seaded\u{001F}Jaga\u{001F}jaga ... kaudu\u{001F}Kohtspikrid\u{001F}Tõlked\u{001F}Ava täisekraan\u{001F}Välju täisekraanist\u{001F}Avaleht\u{001F}Autor: \u{001F}Autorid: \u{001F}Kuupäev: \u{001F}E-post: \u{001F}Laadi meedia alla võrguühenduseta kasutamiseks\u{001F}ebaõnnestus\u{001F}Meedia võrguühenduseta\u{001F}Versioon: \u{001F}Esitlusrežiim\u{001F}Peida navigeerimine\u{001F}Esitlus\u{001F}Slaidid\u{001F}Õpik\u{001F}tõlge pole veel saadaval\u{001F}Veebisaidi QR-kood\u{001F}Suurenda QR-koodi\u{001F}Viga QR-koodi loomisel\u{001F}Õiget vastust pole veel antud\u{001F}Lahendatud vastus\u{001F}Palju õnne, see oli õige vastus\u{001F}Kontrolli\u{001F}Vajuta sihtalal Enterit, et see valida, seejärel vajuta kaardil Enterit, et see sinna paigutada\u{001F}Sihtala\u{001F}tühi\u{001F}Lünk\u{001F}näita vihjet\u{001F}Vastus\u{001F}Kontrolli vastust. Vastus märgitakse õigeks või valeks.\u{001F}Näita lahendust. Ülesanne märgitakse lahendatuks.\u{001F}valik\u{001F}näita lahendust\u{001F}sorteeri kasvavalt\u{001F}sorteeri kahanevalt\u{001F}sortimata\u{001F}Heli välja\u{001F}Heli sisse\u{001F}Enne saatmist tuleb küsimusele vastata.\u{001F}Enne saatmist tuleb vastata igale reale.\u{001F}Saada\u{001F}Täname tagasiside eest!\u{001F}Sisesta tekst...\u{001F}Uuenda\u{001F}Tõlgi Google'iga (eksperimentaalne)\u{001F}/\u{001F}Paus\u{001F}Taasesituse asukoht\u{001F}Eelista brauseri kõnesünteesi\u{001F}Jätka\u{001F}Sinu brauser ei toeta kõnesünteesi. Proovi mõnda teist brauserit.\u{001F}Kasutatakse brauseri sisseehitatud kõnesünteesi."


i18nEu : String
i18nEu =
    "Aa\u{001F}Itxi elkarrizketa-koadroa\u{001F}garbitu bilaketa\u{001F}Editorearen estiloa\u{001F}letra-tamaina: \u{001E}\u{001F}Oin-oharra\u{001F}Oin-oharrak\u{001F}Euskara\u{001F}fitxa berri batean irekitzen da\u{001F}hurrengoa\u{001F}emaitzarik ez\u{001F}emaitza bat\u{001F}erreproduzitu\u{001F}aurrekoa\u{001F}Aldatu panelen tamaina\u{001F}emaitzak\u{001F}Bilatu\u{001F}txikia\u{001F}ertaina\u{001F}handia\u{001F}Saltatu nabigazioa\u{001F}Diapositiba\u{001F}Diapositiben nabigazioa\u{001F}Urratsa\u{001F}gelditu\u{001F}Aurkibidea\u{001F}Handitu\u{001F}Urdina\u{001F}Modu argia\u{001F}Kolorea\u{001F}Modu iluna\u{001F}Lehenetsia\u{001F}Gorria\u{001F}Kolore-eskema\u{001F}Turkesa\u{001F}Horia\u{001F}Barra-diagrama\u{001F}Kutxa-diagrama\u{001F}Diagrama\u{001F}Inbutu-diagrama\u{001F}Erlazio-grafoa\u{001F}Bero-mapa\u{001F}Lerro-diagrama\u{001F}Lerro-grafikoa\u{001F}Mapa\u{001F}Koordenatu paraleloen diagrama\u{001F}Sektore-diagrama\u{001F}Radar-diagrama\u{001F}Sankey diagrama\u{001F}Sakabanatze-diagrama\u{001F}Taula\u{001F}Hitz-hodeia\u{001F}Itxi txata\u{001F}Txat-mezua\u{001F}Irakurri gabeko txat-mezuak dituzu\u{001F}Ireki txata\u{001F}Bidali mezua\u{001F}Egiaztatu gabeko igorlea\u{001F}Kode-blokea\u{001F}arbelean kopiatuta\u{001F}kopiatu arbelean\u{001F}Kode-editorea\u{001F}Exekutatu\u{001F}lehen bertsioa\u{001F}azken bertsioa\u{001F}maximizatu ikuspegia\u{001F}minimizatu ikuspegia\u{001F}hurrengo bertsioa\u{001F}aurreko bertsioa\u{001F}berrezarri sarrera\u{001F}exekutatzen ari da\u{001F}Bidali terminalera\u{001F}terminala\u{001F}Ezkutatu bideo- eta avatar-iruzkinak\u{001F}Doitu ahotsaren tonua\u{001F}Tonua\u{001F}Doitu erreprodukzio-abiadura\u{001F}Abiadura\u{001F}Iruzkinak\u{001F}Ez erabili koloreak soilik\u{001F}Ireki editorea\u{001F}Informazioa\u{001F}Ezarpenak\u{001F}Partekatu\u{001F}partekatu ... bidez\u{001F}Tresna-aholkuak\u{001F}Itzulpenak\u{001F}Sartu pantaila osoko moduan\u{001F}Irten pantaila osoko modutik\u{001F}Hasiera\u{001F}Egilea: \u{001F}Egileak: \u{001F}Data: \u{001F}Posta elektronikoa: \u{001F}Deskargatu multimedia lineaz kanpo erabiltzeko\u{001F}huts egin du\u{001F}Multimedia lineaz kanpo\u{001F}Bertsioa: \u{001F}Aurkezpen-modua\u{001F}Ezkutatu nabigazioa\u{001F}Aurkezpena\u{001F}Diapositibak\u{001F}Testuliburua\u{001F}oraindik ez dago itzulpenik\u{001F}Webgunearen QR kodea\u{001F}Handitu QR kodea\u{001F}Errorea QR kodea sortzean\u{001F}Oraindik ez da erantzun zuzena eman\u{001F}Agerian jarritako erantzuna\u{001F}Zorionak, hori zen erantzun zuzena\u{001F}Egiaztatu\u{001F}Sakatu Enter jaregite-eremu batean hura hautatzeko, eta gero Enter txartel batean bertan kokatzeko\u{001F}Jaregite-eremua\u{001F}hutsik\u{001F}Hutsunea\u{001F}erakutsi pista\u{001F}Erantzuna\u{001F}Egiaztatu erantzuna. Erantzuna zuzen edo oker gisa markatuko da.\u{001F}Erakutsi ebazpena. Ariketa ebatzita dagoela markatuko da.\u{001F}hautaketa\u{001F}erakutsi ebazpena\u{001F}ordenatu gorantz\u{001F}ordenatu beherantz\u{001F}ordenatu gabe\u{001F}Desaktibatu soinua\u{001F}Aktibatu soinua\u{001F}Galderari erantzun behar zaio bidali aurretik.\u{001F}Errenkada guztiei erantzun behar zaie bidali aurretik.\u{001F}Bidali\u{001F}Eskerrik asko zure iritziagatik!\u{001F}Idatzi testua...\u{001F}Eguneratu\u{001F}Itzuli Google-rekin (esperimentala)\u{001F}/\u{001F}Pausatu\u{001F}Erreprodukzio-posizioa\u{001F}Lehenetsi nabigatzailearen hizketa-sintesia\u{001F}Jarraitu\u{001F}Zure nabigatzaileak ez du hizketa-sintesia onartzen. Probatu beste bat.\u{001F}Nabigatzailearen hizketa-sintesi integratua erabiltzen ari da."


i18nFa : String
i18nFa =
    "اب\u{001F}بستن کادر محاوره\u{001F}جستجو را حذف کنید\u{001F}به سبک ویرایشگر\u{001F}اندازه قلم: \u{001E}\u{001F}پانویس\u{001F}پانویس‌ها\u{001F}فارسی\u{001F}در زبانه جدید باز می‌شود\u{001F}بعدی\u{001F}هیچ نتیجه ای\u{001F}یک نتیجه\u{001F}پخش\u{001F}قبلی\u{001F}تغییر اندازهٔ بخش‌ها\u{001F}نتایج\u{001F}جستجو\u{001F}کوچک\u{001F}متوسط\u{001F}بزرگ\u{001F}رد شدن از پیمایش\u{001F}اسلاید\u{001F}پیمایش اسلایدها\u{001F}مرحله\u{001F}توقف\u{001F}فهرست مطالب\u{001F}بزرگ‌نمایی\u{001F}آبی\u{001F}حالت روشن\u{001F}رنگ\u{001F}حالت تاریک\u{001F}پیش‌فرض\u{001F}قرمز\u{001F}طرح رنگی\u{001F}فیروزه‌ای\u{001F}زرد\u{001F}نمودار میله‌ای\u{001F}نمودار جعبه‌ای\u{001F}نمودار\u{001F}نمودار قیفی\u{001F}گراف روابط\u{001F}نقشهٔ حرارتی\u{001F}نمودار خطی\u{001F}گراف خطی\u{001F}نقشه\u{001F}نمودار مختصات موازی\u{001F}نمودار دایره‌ای\u{001F}نمودار راداری\u{001F}نمودار سنکی\u{001F}نمودار پراکندگی\u{001F}جدول\u{001F}ابر واژگان\u{001F}بستن گفتگو\u{001F}پیام گفتگو\u{001F}پیام‌های گفتگوی خوانده‌نشده دارید\u{001F}باز کردن گفتگو\u{001F}ارسال پیام\u{001F}فرستندهٔ تأییدنشده\u{001F}بلوک کد\u{001F}در کلیپ بورد کپی شد\u{001F}کپی در کلیپ بورد\u{001F}ویرایشگر کد\u{001F}اجرا\u{001F}نسخه اولیه\u{001F}آخرین نسخه\u{001F}بزرگ کردن پنجره\u{001F}کوچک کردن پنجره\u{001F}نسخه بعدی\u{001F}نسخه قبلی\u{001F}بازنشانی ورودی\u{001F}در حال اجرا\u{001F}ارسال به پایانه\u{001F}پایانه\u{001F}پنهان کردن توضیحات ویدیو و آواتار\u{001F}تنظیم زیر و بمی صدا\u{001F}زیر و بمی\u{001F}تنظیم سرعت پخش\u{001F}سرعت\u{001F}توضیحات\u{001F}عدم اتکا تنها به رنگ\u{001F}باز کردن ویرایشگر\u{001F}اطلاعات\u{001F}تنظیمات\u{001F}اشتراک‌گذاری\u{001F}اشتراک گذاری از طریق ...\u{001F}راهنمای ابزار\u{001F}ترجمه ها\u{001F}ورود به حالت تمام صفحه\u{001F}خروج از حالت تمام صفحه\u{001F}خانه\u{001F}نویسنده: \u{001F}نویسندگان: \u{001F}تاریخ: \u{001F}ایمیل: \u{001F}دانلود رسانه‌ها برای استفادهٔ آفلاین\u{001F}ناموفق\u{001F}رسانه‌ها آفلاین\u{001F}نسخه: \u{001F}حالت ارائه\u{001F}پنهان کردن ناوبری\u{001F}ارائه\u{001F}اسلایدها\u{001F}کتاب درسی\u{001F}هنوز ترجمه‌ای وجود ندارد\u{001F}کد QR برای وب سایت\u{001F}بزرگ‌نمایی کد QR\u{001F}خطا هنگام رمزگذاری روی کد QR\u{001F}پاسخ درست هنوز داده نشده است\u{001F}پاسخ حل شده\u{001F}تبریک می‌گویم، پاسخ درست بود\u{001F}بررسی\u{001F}روی یک ناحیهٔ رهاسازی Enter را بزنید تا انتخاب شود، سپس روی یک کارت Enter را بزنید تا در آنجا قرار گیرد\u{001F}ناحیهٔ رهاسازی\u{001F}خالی\u{001F}جای خالی\u{001F}نمایش راهنمایی\u{001F}پاسخ\u{001F}پاسخ را بررسی کنید. پاسخ به‌عنوان درست یا نادرست علامت‌گذاری می‌شود.\u{001F}راه‌حل را نشان دهید. آزمون به‌عنوان حل‌شده علامت‌گذاری می‌شود.\u{001F}انتخاب\u{001F}نمایش راه‌حل\u{001F}مرتب‌سازی صعودی\u{001F}مرتب‌سازی نزولی\u{001F}مرتب‌نشده\u{001F}صدا خاموش\u{001F}صدا روشن\u{001F}پیش از ارسال باید به پرسش پاسخ داده شود.\u{001F}پیش از ارسال باید به همهٔ ردیف‌ها پاسخ داده شود.\u{001F}ارسال\u{001F}از بازخورد شما سپاسگزاریم!\u{001F}لطفا متن وارد کنید\u{001F}به‌روزرسانی\u{001F}ترجمه با Google (آزمایشی)\u{001F}از\u{001F}مکث\u{001F}موقعیت پخش\u{001F}ترجیح تبدیل متن به گفتار مرورگر\u{001F}ادامه\u{001F}مرورگر شما از تبدیل متن به گفتار پشتیبانی نمی‌کند، مرورگر دیگری را امتحان کنید.\u{001F}استفاده از موتور داخلی تبدیل متن به گفتار مرورگر."


i18nFi : String
i18nFi =
    "Aa\u{001F}Sulje valintaikkuna\u{001F}tyhjennä haku\u{001F}Editorin tyyli\u{001F}fonttikoko: \u{001E}\u{001F}Alaviite\u{001F}Alaviitteet\u{001F}Suomi\u{001F}avautuu uudelle välilehdelle\u{001F}seuraava\u{001F}ei tuloksia\u{001F}yksi tulos\u{001F}toista\u{001F}edellinen\u{001F}Muuta ruutujen kokoa\u{001F}tulokset\u{001F}Hae\u{001F}pieni\u{001F}keskikokoinen\u{001F}suuri\u{001F}Ohita navigointi\u{001F}Dia\u{001F}Dianavigointi\u{001F}Vaihe\u{001F}pysäytä\u{001F}Sisällysluettelo\u{001F}Suurenna\u{001F}Sininen\u{001F}Vaalea tila\u{001F}Väri\u{001F}Tumma tila\u{001F}Oletus\u{001F}Punainen\u{001F}Värimalli\u{001F}Turkoosi\u{001F}Keltainen\u{001F}Pylväskaavio\u{001F}Laatikkokaavio\u{001F}Kaavio\u{001F}Suppilokaavio\u{001F}Suhdeverkko\u{001F}Lämpökartta\u{001F}Viivakaavio\u{001F}Viivakuvaaja\u{001F}Kartta\u{001F}Rinnakkaiskoordinaattikaavio\u{001F}Ympyräkaavio\u{001F}Tutkakaavio\u{001F}Sankey-kaavio\u{001F}Hajontakaavio\u{001F}Taulukko\u{001F}Sanapilvi\u{001F}Sulje keskustelu\u{001F}Keskusteluviesti\u{001F}Sinulla on lukemattomia keskusteluviestejä\u{001F}Avaa keskustelu\u{001F}Lähetä viesti\u{001F}Vahvistamaton lähettäjä\u{001F}Koodilohko\u{001F}kopioitu leikepöydälle\u{001F}kopioi leikepöydälle\u{001F}Koodieditori\u{001F}Suorita\u{001F}ensimmäinen versio\u{001F}viimeinen versio\u{001F}suurenna näkymä\u{001F}pienennä näkymä\u{001F}seuraava versio\u{001F}edellinen versio\u{001F}palauta syöte\u{001F}käynnissä\u{001F}Lähetä päätteeseen\u{001F}pääte\u{001F}Piilota video- ja avatarikommentit\u{001F}Säädä äänenkorkeutta\u{001F}Korkeus\u{001F}Säädä toistonopeutta\u{001F}Nopeus\u{001F}Kommentit\u{001F}Älä luota pelkkiin väreihin\u{001F}Avaa editori\u{001F}Tiedot\u{001F}Asetukset\u{001F}Jaa\u{001F}jaa palvelussa ...\u{001F}Työkaluvihjeet\u{001F}Käännökset\u{001F}Siirry koko näytön tilaan\u{001F}Poistu koko näytön tilasta\u{001F}Etusivu\u{001F}Tekijä: \u{001F}Tekijät: \u{001F}Päivämäärä: \u{001F}Sähköposti: \u{001F}Lataa media offline-käyttöön\u{001F}epäonnistui\u{001F}Media offline-tilassa\u{001F}Versio: \u{001F}Esitystila\u{001F}Piilota navigointi\u{001F}Esitys\u{001F}Diat\u{001F}Oppikirja\u{001F}käännöstä ei vielä ole\u{001F}Verkkosivuston QR-koodi\u{001F}Suurenna QR-koodi\u{001F}Virhe QR-koodin luonnissa\u{001F}Oikeaa vastausta ei ole vielä annettu\u{001F}Paljastettu vastaus\u{001F}Onnittelut, vastaus oli oikein\u{001F}Tarkista\u{001F}Valitse pudotusalue painamalla siinä Enteriä ja paina sitten kortissa Enteriä sijoittaaksesi sen sinne\u{001F}Pudotusalue\u{001F}tyhjä\u{001F}Aukko\u{001F}näytä vihje\u{001F}Vastaus\u{001F}Tarkista vastaus. Vastaus merkitään oikeaksi tai vääräksi.\u{001F}Näytä ratkaisu. Tehtävä merkitään ratkaistuksi.\u{001F}valinta\u{001F}näytä ratkaisu\u{001F}lajittele nousevasti\u{001F}lajittele laskevasti\u{001F}ei lajiteltu\u{001F}Ääni pois\u{001F}Ääni päälle\u{001F}Kysymykseen on vastattava ennen lähettämistä.\u{001F}Jokaiseen riviin on vastattava ennen lähettämistä.\u{001F}Lähetä\u{001F}Kiitos palautteestasi!\u{001F}Kirjoita tekstiä...\u{001F}Päivitä\u{001F}Käännä Googlella (kokeellinen)\u{001F}/\u{001F}Tauko\u{001F}Toistokohta\u{001F}Suosi selaimen puhesynteesiä\u{001F}Jatka\u{001F}Selaimesi ei tue puhesynteesiä. Kokeile toista selainta.\u{001F}Käytetään selaimen sisäänrakennettua puhesynteesiä."


i18nFr : String
i18nFr =
    "Aa\u{001F}Fermer la boîte de dialogue\u{001F}Effacer la recherche\u{001F}Style de l'éditeur\u{001F}Taille de police : \u{001E}\u{001F}Note de bas de page\u{001F}Notes de bas de page\u{001F}Français\u{001F}s'ouvre dans un nouvel onglet\u{001F}suivant\u{001F}aucun résultat\u{001F}un résultat\u{001F}Lecture\u{001F}précédent\u{001F}Redimensionner les volets\u{001F}Résultats\u{001F}Recherche\u{001F}petit\u{001F}moyen\u{001F}grand\u{001F}Passer la navigation\u{001F}Diapositive\u{001F}Navigation entre les diapositives\u{001F}Étape\u{001F}Arrêt\u{001F}Table des matières\u{001F}Agrandir\u{001F}Bleu\u{001F}Mode clair\u{001F}Couleur\u{001F}Mode sombre\u{001F}Standard\u{001F}Rouge\u{001F}Schéma de couleurs\u{001F}Turquoise\u{001F}Jaune\u{001F}Diagramme en bâtons\u{001F}Boîte à moustaches\u{001F}Graphique\u{001F}Entonnoir\u{001F}Graphe de relations\u{001F}Carte de chaleur\u{001F}Graphique linéaire\u{001F}Graphe linéaire\u{001F}Carte\u{001F}Carte de coordonnées parallèles\u{001F}Diagramme en secteurs\u{001F}Graphique en radar\u{001F}Diagramme de Sankey\u{001F}Nuage de points\u{001F}Tableau\u{001F}Nuage de mots\u{001F}Fermer le chat\u{001F}Message de chat\u{001F}Vous avez des messages de chat non lus\u{001F}Ouvrir le chat\u{001F}Envoyer le message\u{001F}Expéditeur non vérifié\u{001F}Bloc de code\u{001F}Copié dans le presse-papiers\u{001F}Copier dans le presse-papiers\u{001F}Éditeur de code\u{001F}Exécuter\u{001F}première version\u{001F}dernière version\u{001F}Maximiser l'affichage\u{001F}Réduire l'affichage\u{001F}version suivante\u{001F}version précédente\u{001F}réinitialiser la saisie\u{001F}en cours d'exécution\u{001F}Envoyer au terminal\u{001F}Terminal\u{001F}Masquer les commentaires vidéo et avatar\u{001F}Ajuster la hauteur du son\u{001F}Hauteur\u{001F}Ajuster la vitesse de lecture\u{001F}Vitesse\u{001F}Commentaires\u{001F}Ne pas se fier uniquement aux couleurs\u{001F}Ouvrir l'éditeur\u{001F}Informations\u{001F}Paramètres\u{001F}Partager\u{001F}Partager via ...\u{001F}Infobulles\u{001F}Traductions\u{001F}Passer en plein écran\u{001F}Quitter le plein écran\u{001F}Vue d'ensemble\u{001F}Auteur : \u{001F}Auteurs : \u{001F}Date : \u{001F}Email : \u{001F}Télécharger les médias pour une utilisation hors ligne\u{001F}échoués\u{001F}Médias hors ligne\u{001F}Version : \u{001F}Mode de présentation\u{001F}Masquer la navigation\u{001F}Présentation\u{001F}Diapositives\u{001F}Manuel\u{001F}traductions non disponibles\u{001F}Code QR pour site web\u{001F}Agrandir le code QR\u{001F}Erreur lors de l'encodage en code QR\u{001F}La réponse correcte n'a pas encore été donnée\u{001F}Réponse résolue\u{001F}Félicitations, c'était la bonne réponse\u{001F}Vérifier\u{001F}Appuyez sur Entrée sur une zone de dépôt pour la sélectionner, puis sur Entrée sur une carte pour l'y placer\u{001F}Zone de dépôt\u{001F}vide\u{001F}Trou\u{001F}Afficher l'indice\u{001F}Réponse\u{001F}Vérifiez la réponse. La réponse sera marquée comme correcte ou incorrecte.\u{001F}Affichez la solution. Le quiz sera marqué comme résolu.\u{001F}Sélection\u{001F}Afficher la solution\u{001F}trier par ordre croissant\u{001F}trier par ordre décroissant\u{001F}non trié\u{001F}Haut-parleur désactivé\u{001F}Haut-parleur activé\u{001F}Il faut répondre à la question avant l'envoi.\u{001F}Il faut répondre à chaque ligne avant l'envoi.\u{001F}Soumettre\u{001F}Merci pour vos commentaires !\u{001F}Saisie de texte ...\u{001F}Mettre à jour\u{001F}Traduire avec Google (expérimental)\u{001F}sur\u{001F}Pause\u{001F}Position de lecture\u{001F}Préférer la synthèse vocale du navigateur\u{001F}Reprendre\u{001F}Votre navigateur ne prend pas en charge la synthèse vocale, essayez-en un autre.\u{001F}Utilisation du moteur de synthèse vocale intégré du navigateur."


i18nGa : String
i18nGa =
    "Aa\u{001F}Dún an bosca dialóige\u{001F}glan an cuardach\u{001F}Stíl an eagarthóra\u{001F}clómhéid: \u{001E}\u{001F}Fonóta\u{001F}Fonótaí\u{001F}Gaeilge\u{001F}osclaítear i gcluaisín nua é\u{001F}ar aghaidh\u{001F}gan torthaí\u{001F}toradh amháin\u{001F}seinn\u{001F}siar\u{001F}Athraigh méid na bpainéal\u{001F}torthaí\u{001F}Cuardaigh\u{001F}beag\u{001F}meánach\u{001F}mór\u{001F}Léim thar an nascleanúint\u{001F}Sleamhnán\u{001F}Nascleanúint sleamhnán\u{001F}Céim\u{001F}stop\u{001F}Clár na nÁbhar\u{001F}Méadaigh\u{001F}Gorm\u{001F}Mód geal\u{001F}Dath\u{001F}Mód dorcha\u{001F}Réamhshocrú\u{001F}Dearg\u{001F}Scéim dathanna\u{001F}Turcaid\u{001F}Buí\u{001F}Barrachairt\u{001F}Boscaplot\u{001F}Cairt\u{001F}Cairt tonnadóra\u{001F}Graf gaolmhaireachtaí\u{001F}Léarscáil teasa\u{001F}Línechairt\u{001F}Líneghraf\u{001F}Léarscáil\u{001F}Cairt comhordanáidí comhthreomhara\u{001F}Píchairt\u{001F}Cairt radair\u{001F}Léaráid Sankey\u{001F}Scaipghraf\u{001F}Tábla\u{001F}Scamall focal\u{001F}Dún an comhrá\u{001F}Teachtaireacht chomhrá\u{001F}Tá teachtaireachtaí comhrá neamhléite agat\u{001F}Oscail an comhrá\u{001F}Seol teachtaireacht\u{001F}Seoltóir neamhfhíoraithe\u{001F}Bloc cóid\u{001F}cóipeáilte chuig an ngearrthaisce\u{001F}cóipeáil chuig an ngearrthaisce\u{001F}Eagarthóir cóid\u{001F}Rith\u{001F}an chéad leagan\u{001F}an leagan deireanach\u{001F}uasmhéadaigh an t-amharc\u{001F}íoslaghdaigh an t-amharc\u{001F}an chéad leagan eile\u{001F}an leagan roimhe\u{001F}athshocraigh an t-ionchur\u{001F}ag rith\u{001F}Seol chuig an teirminéal\u{001F}teirminéal\u{001F}Folaigh nótaí tráchta físe agus abhatáir\u{001F}Coigeartaigh tuinairde an ghutha\u{001F}Tuinairde\u{001F}Coigeartaigh luas na hathsheinnte\u{001F}Luas\u{001F}Nótaí tráchta\u{001F}Ná bí ag brath ar dhath amháin\u{001F}Oscail an t-eagarthóir\u{001F}Eolas\u{001F}Socruithe\u{001F}Comhroinn\u{001F}comhroinn trí ...\u{001F}Leideanna uirlisí\u{001F}Aistriúcháin\u{001F}Téigh go lánscáileán\u{001F}Scoir den lánscáileán\u{001F}Baile\u{001F}Údar: \u{001F}Údair: \u{001F}Dáta: \u{001F}Ríomhphost: \u{001F}Íoslódáil meáin le húsáid as líne\u{001F}theip\u{001F}Meáin as líne\u{001F}Leagan: \u{001F}Mód cur i láthair\u{001F}Folaigh an nascleanúint\u{001F}Cur i láthair\u{001F}Sleamhnáin\u{001F}Téacsleabhar\u{001F}níl aistriúchán ar fáil fós\u{001F}Cód QR don suíomh gréasáin\u{001F}Méadaigh an cód QR\u{001F}Earráid agus cód QR á chruthú\u{001F}Níor tugadh an freagra ceart fós\u{001F}Freagra nochta\u{001F}Comhghairdeas, ba é sin an freagra ceart\u{001F}Seiceáil\u{001F}Brúigh Enter ar limistéar scaoilte chun é a roghnú, ansin Enter ar chárta chun é a chur ann\u{001F}Limistéar scaoilte\u{001F}folamh\u{001F}Bearna\u{001F}taispeáin leid\u{001F}Freagra\u{001F}Seiceáil an freagra. Marcálfar an freagra mar cheart nó mícheart.\u{001F}Taispeáin an réiteach. Marcálfar an cleachtadh mar réitithe.\u{001F}roghnú\u{001F}taispeáin an réiteach\u{001F}sórtáil in ord ardaitheach\u{001F}sórtáil in ord íslitheach\u{001F}gan sórtáil\u{001F}Fuaim múchta\u{001F}Fuaim ar siúl\u{001F}Caithfear an cheist a fhreagairt roimh sheoladh.\u{001F}Caithfear gach ró a fhreagairt roimh sheoladh.\u{001F}Seol\u{001F}Go raibh maith agat as d'aiseolas!\u{001F}Cuir téacs isteach...\u{001F}Nuashonraigh\u{001F}Aistrigh le Google (turgnamhach)\u{001F}as\u{001F}Sos\u{001F}Suíomh athsheinnte\u{001F}Tabhair tús áite do shintéis cainte an bhrabhsálaí\u{001F}Atosaigh\u{001F}Ní thacaíonn do bhrabhsálaí le sintéis cainte. Bain triail as brabhsálaí eile.\u{001F}Tá sintéis cainte ionsuite an bhrabhsálaí in úsáid."


i18nHi : String
i18nHi =
    "अआ\u{001F}डायलॉग बंद करें\u{001F}खोज हटाएं\u{001F}संपादक शैली\u{001F}फ़ॉन्ट आकार: \u{001E}\u{001F}फ़ुटनोट\u{001F}फ़ुटनोट्स\u{001F}हिन्दी\u{001F}नए टैब में खुलता है\u{001F}जारी रखें\u{001F}कोई परिणाम नहीं\u{001F}एक परिणाम\u{001F}प्लेबैक\u{001F}वापस\u{001F}पैनल का आकार बदलें\u{001F}परिणाम\u{001F}खोजें\u{001F}छोटा\u{001F}मध्यम\u{001F}बड़ा\u{001F}नेविगेशन छोड़ें\u{001F}स्लाइड\u{001F}स्लाइड नेविगेशन\u{001F}चरण\u{001F}रोकें\u{001F}विषय सूची\u{001F}बड़ा करें\u{001F}नीला\u{001F}लाइट मोड\u{001F}रंग\u{001F}डार्क मोड\u{001F}डिफ़ॉल्ट\u{001F}लाल\u{001F}रंग योजना\u{001F}फ़िरोज़ा\u{001F}पीला\u{001F}बार चार्ट\u{001F}बॉक्सप्लॉट\u{001F}चार्ट\u{001F}फ़नल चार्ट\u{001F}रिलेशनशिप ग्राफ\u{001F}हीटमैप\u{001F}लाइन चार्ट\u{001F}लाइन ग्राफ\u{001F}मैप\u{001F}समानांतर समन्वय मानचित्र\u{001F}पाई चार्ट\u{001F}रडार चार्ट\u{001F}सैंके आरेख\u{001F}स्कैटरप्लॉट\u{001F}तालिका\u{001F}वर्ड क्लाउड\u{001F}चैट बंद करें\u{001F}चैट संदेश\u{001F}आपके पास अपठित चैट संदेश हैं\u{001F}चैट खोलें\u{001F}संदेश भेजें\u{001F}असत्यापित प्रेषक\u{001F}कोड ब्लॉक\u{001F}क्लिपबोर्ड पर कॉपी हो गया\u{001F}क्लिपबोर्ड पर कॉपी करें\u{001F}कोड संपादक\u{001F}चलाएँ\u{001F}पहला संस्करण\u{001F}अंतिम संस्करण\u{001F}प्रदर्शन को अधिकतम करें\u{001F}प्रदर्शन को छोटा करें\u{001F}अगला संस्करण\u{001F}पिछला संस्करण\u{001F}इनपुट रीसेट करें\u{001F}चल रहा है\u{001F}टर्मिनल पर भेजें\u{001F}टर्मिनल\u{001F}वीडियो और अवतार टिप्पणियाँ छुपाएं\u{001F}पिच सेट करें\u{001F}पिच\u{001F}प्लेबैक गति सेट करें\u{001F}गति\u{001F}टिप्पणियाँ\u{001F}केवल रंग पर निर्भर न रहें\u{001F}संपादक खोलें\u{001F}सूचना\u{001F}सेटिंग्स\u{001F}शेयर करें\u{001F}के माध्यम से साझा करें ...\u{001F}टूलटिप्स\u{001F}अनुवाद\u{001F}पूर्ण स्क्रीन में जाएं\u{001F}पूर्ण स्क्रीन से बाहर निकलें\u{001F}सिंहावलोकन\u{001F}लेखक: \u{001F}लेखक: \u{001F}तारीख: \u{001F}ईमेल: \u{001F}ऑफ़लाइन उपयोग के लिए मीडिया डाउनलोड करें\u{001F}विफल\u{001F}मीडिया ऑफ़लाइन\u{001F}संस्करण: \u{001F}प्रेजेंटेशन मोड\u{001F}नेविगेशन छिपाएँ\u{001F}प्रस्तुति\u{001F}स्लाइड्स\u{001F}पाठ्यपुस्तक\u{001F}अभी तक कोई अनुवाद उपलब्ध नहीं है\u{001F}वेबसाइट के लिए क्यूआर कोड\u{001F}क्यूआर कोड बड़ा करें\u{001F}क्यूआर कोड को एनकोड करने में त्रुटि\u{001F}अभी तक सही उत्तर नहीं दिया गया है\u{001F}हल किया गया उत्तर\u{001F}बधाई हो, यह सही उत्तर था\u{001F}चेक करें\u{001F}ड्रॉप ज़ोन चुनने के लिए उस पर Enter दबाएँ, फिर किसी कार्ड को वहाँ रखने के लिए उस पर Enter दबाएँ\u{001F}ड्रॉप ज़ोन\u{001F}खाली\u{001F}रिक्त स्थान\u{001F}संकेत दिखाएं\u{001F}उत्तर\u{001F}उत्तर की जाँच करें। उत्तर को सही या गलत के रूप में चिह्नित किया जाएगा।\u{001F}समाधान दिखाएं। प्रश्नोत्तरी को समाधान के रूप में चिह्नित किया जाएगा।\u{001F}चयन\u{001F}समाधान दिखाएं\u{001F}आरोही क्रमबद्ध करें\u{001F}अवरोही क्रमबद्ध करें\u{001F}क्रमबद्ध नहीं\u{001F}स्पीकर बंद\u{001F}स्पीकर ऑन\u{001F}सबमिट करने से पहले प्रश्न का उत्तर दिया जाना चाहिए।\u{001F}सबमिट करने से पहले हर पंक्ति का उत्तर दिया जाना चाहिए।\u{001F}सबमिट करें\u{001F}आपकी प्रतिक्रिया के लिए धन्यवाद!\u{001F}टेक्स्ट इनपुट ...\u{001F}अपडेट करें\u{001F}Google के साथ अनुवाद करें (प्रायोगिक)\u{001F}/\u{001F}विराम\u{001F}प्लेबैक स्थिति\u{001F}ब्राउज़र के टेक्स्ट-टू-स्पीच को प्राथमिकता दें\u{001F}फिर से शुरू करें\u{001F}आपका ब्राउज़र टेक्स्ट-टू-स्पीच का समर्थन नहीं करता है, कोई दूसरा ब्राउज़र आज़माएँ।\u{001F}ब्राउज़र के आंतरिक टेक्स्ट-टू-स्पीच इंजन का उपयोग किया जा रहा है।"


i18nHr : String
i18nHr =
    "Aa\u{001F}Zatvori dijalog\u{001F}očisti pretragu\u{001F}Stil uređivača\u{001F}veličina fonta: \u{001E}\u{001F}Fusnota\u{001F}Fusnote\u{001F}Hrvatski\u{001F}otvara se u novoj kartici\u{001F}sljedeće\u{001F}nema rezultata\u{001F}jedan rezultat\u{001F}reproduciraj\u{001F}prethodno\u{001F}Promijeni veličinu okna\u{001F}rezultati\u{001F}Traži\u{001F}mala\u{001F}srednja\u{001F}velika\u{001F}Preskoči navigaciju\u{001F}Slajd\u{001F}Navigacija slajdova\u{001F}Korak\u{001F}zaustavi\u{001F}Sadržaj\u{001F}Povećaj\u{001F}Plava\u{001F}Svijetli način\u{001F}Boja\u{001F}Tamni način\u{001F}Zadano\u{001F}Crvena\u{001F}Shema boja\u{001F}Tirkizna\u{001F}Žuta\u{001F}Stupčasti grafikon\u{001F}Kutijasti dijagram\u{001F}Grafikon\u{001F}Ljevkasti grafikon\u{001F}Graf odnosa\u{001F}Toplinska karta\u{001F}Linijski grafikon\u{001F}Linijski graf\u{001F}Karta\u{001F}Dijagram paralelnih koordinata\u{001F}Tortni grafikon\u{001F}Radarski grafikon\u{001F}Sankeyjev dijagram\u{001F}Raspršeni grafikon\u{001F}Tablica\u{001F}Oblak riječi\u{001F}Zatvori razgovor\u{001F}Poruka u razgovoru\u{001F}Imaš nepročitane poruke u razgovoru\u{001F}Otvori razgovor\u{001F}Pošalji poruku\u{001F}Neprovjereni pošiljatelj\u{001F}Blok koda\u{001F}kopirano u međuspremnik\u{001F}kopiraj u međuspremnik\u{001F}Uređivač koda\u{001F}Pokreni\u{001F}prva verzija\u{001F}posljednja verzija\u{001F}maksimiziraj prikaz\u{001F}minimiziraj prikaz\u{001F}sljedeća verzija\u{001F}prethodna verzija\u{001F}poništi unos\u{001F}izvodi se\u{001F}Pošalji u terminal\u{001F}terminal\u{001F}Sakrij komentare videa i avatara\u{001F}Prilagodi visinu glasa\u{001F}Visina\u{001F}Prilagodi brzinu reprodukcije\u{001F}Brzina\u{001F}Komentari\u{001F}Ne oslanjaj se samo na boju\u{001F}Otvori uređivač\u{001F}Informacije\u{001F}Postavke\u{001F}Podijeli\u{001F}podijeli putem ...\u{001F}Opisi alata\u{001F}Prijevodi\u{001F}Uključi prikaz preko cijelog zaslona\u{001F}Izađi iz prikaza preko cijelog zaslona\u{001F}Početna\u{001F}Autor: \u{001F}Autori: \u{001F}Datum: \u{001F}E-pošta: \u{001F}Preuzmi medije za izvanmrežnu upotrebu\u{001F}neuspjelo\u{001F}Mediji izvan mreže\u{001F}Verzija: \u{001F}Način prezentacije\u{001F}Sakrij navigaciju\u{001F}Prezentacija\u{001F}Slajdovi\u{001F}Udžbenik\u{001F}prijevod još nije dostupan\u{001F}QR kod za web-stranicu\u{001F}Povećaj QR kod\u{001F}Pogreška pri izradi QR koda\u{001F}Točan odgovor još nije dan\u{001F}Otkriveni odgovor\u{001F}Čestitamo, to je bio točan odgovor\u{001F}Provjeri\u{001F}Pritisni Enter na polju za ispuštanje da ga odabereš, zatim Enter na kartici da je postaviš ondje\u{001F}Polje za ispuštanje\u{001F}prazno\u{001F}Praznina\u{001F}prikaži savjet\u{001F}Odgovor\u{001F}Provjeri odgovor. Odgovor će biti označen kao točan ili netočan.\u{001F}Prikaži rješenje. Zadatak će biti označen kao riješen.\u{001F}odabir\u{001F}prikaži rješenje\u{001F}sortiraj uzlazno\u{001F}sortiraj silazno\u{001F}nije sortirano\u{001F}Isključi zvuk\u{001F}Uključi zvuk\u{001F}Prije slanja potrebno je odgovoriti na pitanje.\u{001F}Prije slanja potrebno je odgovoriti na svaki redak.\u{001F}Pošalji\u{001F}Hvala na povratnim informacijama!\u{001F}Unesi tekst...\u{001F}Ažuriraj\u{001F}Prevedi pomoću Googlea (eksperimentalno)\u{001F}od\u{001F}Pauziraj\u{001F}Položaj reprodukcije\u{001F}Daj prednost sintezi govora preglednika\u{001F}Nastavi\u{001F}Tvoj preglednik ne podržava sintezu govora. Isprobaj drugi.\u{001F}Koristi se ugrađena sinteza govora preglednika."


i18nHu : String
i18nHu =
    "Aa\u{001F}Párbeszédablak bezárása\u{001F}keresés törlése\u{001F}Szerkesztő stílusa\u{001F}betűméret: \u{001E}\u{001F}Lábjegyzet\u{001F}Lábjegyzetek\u{001F}Magyar\u{001F}új lapon nyílik meg\u{001F}következő\u{001F}nincs találat\u{001F}egy találat\u{001F}lejátszás\u{001F}előző\u{001F}Panelek átméretezése\u{001F}találatok\u{001F}Keresés\u{001F}kicsi\u{001F}közepes\u{001F}nagy\u{001F}Navigáció átugrása\u{001F}Dia\u{001F}Dianavigáció\u{001F}Lépés\u{001F}leállítás\u{001F}Tartalomjegyzék\u{001F}Nagyítás\u{001F}Kék\u{001F}Világos mód\u{001F}Szín\u{001F}Sötét mód\u{001F}Alapértelmezett\u{001F}Piros\u{001F}Színséma\u{001F}Türkiz\u{001F}Sárga\u{001F}Oszlopdiagram\u{001F}Dobozdiagram\u{001F}Diagram\u{001F}Tölcsérdiagram\u{001F}Kapcsolati gráf\u{001F}Hőtérkép\u{001F}Vonaldiagram\u{001F}Vonalgrafikon\u{001F}Térkép\u{001F}Párhuzamos koordinátadiagram\u{001F}Kördiagram\u{001F}Sugárdiagram\u{001F}Sankey-diagram\u{001F}Szórásdiagram\u{001F}Táblázat\u{001F}Szófelhő\u{001F}Csevegés bezárása\u{001F}Csevegőüzenet\u{001F}Olvasatlan csevegőüzeneteid vannak\u{001F}Csevegés megnyitása\u{001F}Üzenet küldése\u{001F}Nem ellenőrzött feladó\u{001F}Kódblokk\u{001F}vágólapra másolva\u{001F}másolás a vágólapra\u{001F}Kódszerkesztő\u{001F}Futtatás\u{001F}első verzió\u{001F}utolsó verzió\u{001F}nézet nagyítása\u{001F}nézet kicsinyítése\u{001F}következő verzió\u{001F}előző verzió\u{001F}bevitel visszaállítása\u{001F}fut\u{001F}Küldés a terminálba\u{001F}terminál\u{001F}Videós és avatar-megjegyzések elrejtése\u{001F}Hangmagasság beállítása\u{001F}Magasság\u{001F}Lejátszási sebesség beállítása\u{001F}Tempó\u{001F}Megjegyzések\u{001F}Ne csak a színekre hagyatkozz\u{001F}Szerkesztő megnyitása\u{001F}Információk\u{001F}Beállítások\u{001F}Megosztás\u{001F}megosztás ezen keresztül: ...\u{001F}Eszköztippek\u{001F}Fordítások\u{001F}Teljes képernyő megnyitása\u{001F}Kilépés a teljes képernyőből\u{001F}Kezdőlap\u{001F}Szerző: \u{001F}Szerzők: \u{001F}Dátum: \u{001F}E-mail: \u{001F}Médiafájlok letöltése offline használatra\u{001F}sikertelen\u{001F}Média offline\u{001F}Verzió: \u{001F}Bemutató mód\u{001F}Navigáció elrejtése\u{001F}Bemutató\u{001F}Diák\u{001F}Tankönyv\u{001F}még nincs fordítás\u{001F}A weboldal QR-kódja\u{001F}QR-kód nagyítása\u{001F}Hiba a QR-kód létrehozásakor\u{001F}Még nem adtad meg a helyes választ\u{001F}Felfedett válasz\u{001F}Gratulálunk, ez volt a helyes válasz\u{001F}Ellenőrzés\u{001F}Nyomj Entert egy célterületen a kiválasztásához, majd Entert egy kártyán, hogy oda helyezd\u{001F}Célterület\u{001F}üres\u{001F}Kitöltendő hely\u{001F}tipp megjelenítése\u{001F}Válasz\u{001F}A válasz ellenőrzése. A válasz helyesnek vagy helytelennek lesz jelölve.\u{001F}A megoldás megjelenítése. A feladat megoldottként lesz jelölve.\u{001F}kiválasztás\u{001F}megoldás megjelenítése\u{001F}növekvő rendezés\u{001F}csökkenő rendezés\u{001F}rendezetlen\u{001F}Hang kikapcsolása\u{001F}Hang bekapcsolása\u{001F}Küldés előtt meg kell válaszolni a kérdést.\u{001F}Küldés előtt minden sort meg kell válaszolni.\u{001F}Küldés\u{001F}Köszönjük a visszajelzésedet!\u{001F}Írj be szöveget...\u{001F}Frissítés\u{001F}Fordítás a Google segítségével (kísérleti)\u{001F}/\u{001F}Szünet\u{001F}Lejátszási pozíció\u{001F}A böngésző beszédszintézisének előnyben részesítése\u{001F}Folytatás\u{001F}A böngésződ nem támogatja a beszédszintézist. Próbálj ki egy másikat.\u{001F}A böngésző beépített beszédszintetizátora van használatban."


i18nHy : String
i18nHy =
    "Աա\u{001F}Փակել երկխոսության պատուհանը\u{001F}մաքրել որոնումը\u{001F}Խմբագրիչի ոճ\u{001F}Տառաչափ՝ \u{001E}\u{001F}Ծանոթագրություն\u{001F}Ծանոթագրություններ\u{001F}հայերեն\u{001F}բացվում է նոր ներդիրում\u{001F}հաջորդը\u{001F}արդյունք չկա\u{001F}մեկ արդյունք\u{001F}նվագարկել\u{001F}նախորդը\u{001F}Փոխել վահանակների չափը\u{001F}արդյունքներ\u{001F}որոնել\u{001F}փոքր\u{001F}միջին\u{001F}մեծ\u{001F}Բաց թողնել նավիգացիան\u{001F}Սլայդ\u{001F}Սլայդների նավիգացիա\u{001F}Քայլ\u{001F}կանգնեցնել\u{001F}բովանդակություն\u{001F}Մեծացնել\u{001F}կապույտ\u{001F}Բաց ռեժիմ\u{001F}գույն\u{001F}Մուգ ռեժիմ\u{001F}կանխադրված\u{001F}կարմիր\u{001F}Գունային սխեմա\u{001F}փիրուզագույն\u{001F}դեղին\u{001F}Սյունակային գծապատկեր\u{001F}Արկղային գծապատկեր\u{001F}Գծապատկեր\u{001F}Ձագարաձև գծապատկեր\u{001F}Կապերի գրաֆ\u{001F}Ջերմային քարտեզ\u{001F}Գծային գծապատկեր\u{001F}Գծային գրաֆիկ\u{001F}Քարտեզ\u{001F}Զուգահեռ կոորդինատների գծապատկեր\u{001F}Շրջանաձև գծապատկեր\u{001F}Ռադարային գծապատկեր\u{001F}Սանկիի դիագրամ\u{001F}Ցրման գծապատկեր\u{001F}Աղյուսակ\u{001F}Բառերի ամպ\u{001F}Փակել զրույցը\u{001F}Զրույցի հաղորդագրություն\u{001F}Դուք ունեք չկարդացված հաղորդագրություններ զրույցում\u{001F}Բացել զրույցը\u{001F}Ուղարկել հաղորդագրությունը\u{001F}Չհաստատված ուղարկող\u{001F}Կոդի բլոկ\u{001F}Պատճենվել է սեղմատախտակին\u{001F}Պատճենել սեղմատախտակին\u{001F}Կոդի խմբագրիչ\u{001F}գործարկել\u{001F}առաջին տարբերակը\u{001F}վերջին տարբերակը\u{001F}մեծացնել տեսքը\u{001F}փոքրացնել տեսքը\u{001F}հաջորդ տարբերակը\u{001F}նախորդ տարբերակը\u{001F}վերակայել մուտքագրումը\u{001F}գործարկվում է\u{001F}Ուղարկել տերմինալ\u{001F}տերմինալ\u{001F}Թաքցնել տեսանյութի և ավատարի մեկնաբանությունները\u{001F}Կարգավորել ձայնի տոնը\u{001F}Տոն\u{001F}Կարգավորել նվագարկման արագությունը\u{001F}Արագություն\u{001F}Մեկնաբանություններ\u{001F}Չհենվել միայն գույնի վրա\u{001F}Բացել խմբագրիչը\u{001F}տեղեկություններ\u{001F}կարգավորումներ\u{001F}կիսվել\u{001F}կիսվել հետևյալ միջոցով ...\u{001F}Հուշումներ\u{001F}թարգմանություններ\u{001F}Անցնել լիաէկրան ռեժիմի\u{001F}Դուրս գալ լիաէկրան ռեժիմից\u{001F}Գլխավոր\u{001F}հեղինակ: \u{001F}հեղինակներ: \u{001F}ամսաթիվ: \u{001F}էլ. փոստ: \u{001F}Ներբեռնել մեդիան անցանց օգտագործման համար\u{001F}ձախողվել է\u{001F}Մեդիան անցանց\u{001F}տարբերակ: \u{001F}Ներկայացման ռեժիմ\u{001F}Թաքցնել նավարկումը\u{001F}ներկայացում\u{001F}սլայդներ\u{001F}դասագիրք\u{001F}Թարգմանություն դեռ չկա\u{001F}Վեբ կայքի QR կոդ\u{001F}Մեծացնել QR կոդը\u{001F}Սխալ QR կոդի կոդավորման ժամանակ\u{001F}Ճիշտ պատասխանը դեռևս չի տրվել\u{001F}Լուծված պատասխան\u{001F}Շնորհավորում եմ, դա ճիշտ պատասխանն էր\u{001F}ստուգել\u{001F}Սեղմեք Enter տեղադրման դաշտի վրա՝ այն ընտրելու համար, ապա Enter քարտի վրա՝ այն այնտեղ տեղադրելու համար\u{001F}Տեղադրման դաշտ\u{001F}դատարկ\u{001F}Բացթողում\u{001F}ցույց տալ հուշումը\u{001F}Պատասխան\u{001F}Ստուգեք պատասխանը։ Այն կնշվի որպես ճիշտ կամ սխալ։\u{001F}Ցույց տվեք լուծումը։ Առաջադրանքը կնշվի որպես լուծված։\u{001F}ընտրություն\u{001F}ցույց տալ լուծումը\u{001F}դասավորել աճման կարգով\u{001F}դասավորել նվազման կարգով\u{001F}դասավորված չէ\u{001F}առանց ձայնի\u{001F}ձայնով\u{001F}Ուղարկելուց առաջ պետք է պատասխանել հարցին։\u{001F}Ուղարկելուց առաջ պետք է պատասխանել բոլոր տողերին։\u{001F}Ուղարկել\u{001F}Շնորհակալություն ձեր կարծիքի համար։\u{001F}Մուտքագրեք տեքստ...\u{001F}Թարմացնել\u{001F}Թարգմանել Google-ի միջոցով (փորձնական)\u{001F}/\u{001F}Դադար\u{001F}Նվագարկման դիրքը\u{001F}Նախընտրել դիտարկիչի խոսքի սինթեզը\u{001F}Շարունակել\u{001F}Ձեր դիտարկիչը չի աջակցում խոսքի սինթեզ, փորձեք մեկ ուրիշը։\u{001F}Օգտագործվում է դիտարկիչի ներկառուցված խոսքի սինթեզը։"


i18nIt : String
i18nIt =
    "Aa\u{001F}Chiudi la finestra di dialogo\u{001F}cancella ricerca\u{001F}stile editor\u{001F}Dimensione carattere: \u{001E}\u{001F}Nota\u{001F}Note\u{001F}Italiano\u{001F}si apre in una nuova scheda\u{001F}prossimo\u{001F}non ci sono risultati\u{001F}un risultato\u{001F}avvia\u{001F}precedente\u{001F}Ridimensiona i riquadri\u{001F}risultati\u{001F}Cerca\u{001F}piccolo\u{001F}medio\u{001F}grande\u{001F}Salta la navigazione\u{001F}Diapositiva\u{001F}Navigazione diapositive\u{001F}Passo\u{001F}ferma\u{001F}indice\u{001F}Ingrandisci\u{001F}blu\u{001F}modalità chiara\u{001F}colore\u{001F}modalità scura\u{001F}predefinito\u{001F}rosso\u{001F}Schema di colori\u{001F}turchese\u{001F}giallo\u{001F}Diagramma a barre\u{001F}Diagramma a scatola\u{001F}Grafico\u{001F}Grafico a imbuto\u{001F}Grafico delle relazioni\u{001F}Mappa termica\u{001F}Diagramma a linee\u{001F}Grafico a linee\u{001F}Mappa\u{001F}Mappa a coordinate parallele\u{001F}Diagramma a torta\u{001F}Diagramma Radar\u{001F}Diagramma di Sankey\u{001F}Diagramma a dispersione\u{001F}Tabella\u{001F}Nuvola di parole\u{001F}Chiudere la chat\u{001F}Messaggio della chat\u{001F}Ci sono messaggi di chat non letti\u{001F}Aprire la chat\u{001F}Invia messaggio\u{001F}Mittente non verificato\u{001F}Blocco di codice\u{001F}copiato negli appunti\u{001F}copia negli appunti\u{001F}Editor di codice\u{001F}Esegui\u{001F}prima versione\u{001F}ultima versione\u{001F}massimizzare la vista\u{001F}minimizzare la vista\u{001F}versione seguente\u{001F}versione precedente\u{001F}ripristina l'input\u{001F}in esecuzione\u{001F}Invia al terminale\u{001F}terminale\u{001F}Nascondi i commenti video e avatar\u{001F}Regola l'altezza del tono\u{001F}Tono\u{001F}Regola la velocità di riproduzione\u{001F}Velocità\u{001F}Commenti\u{001F}Non affidarti solo ai colori\u{001F}Apri l'editor\u{001F}Informazioni\u{001F}Impostazioni\u{001F}Condividi\u{001F}Condividi via ...\u{001F}Suggerimenti\u{001F}Traduzioni\u{001F}Entra a schermo intero\u{001F}Esci da schermo intero\u{001F}Home\u{001F}Autore: \u{001F}Autori: \u{001F}Data: \u{001F}Email: \u{001F}Scarica i media per l'uso offline\u{001F}non riusciti\u{001F}Media offline\u{001F}Versione: \u{001F}Modalità presentazione\u{001F}Nascondi navigazione\u{001F}Presentazione\u{001F}Diapositive\u{001F}Manuale\u{001F}ancora non tradotto\u{001F}Codice QR del sito web\u{001F}Ingrandisci il codice QR\u{001F}Errore nel codificare come codice QR\u{001F}La risposta corretta non è stata ancora fornita\u{001F}Risposta rivelata\u{001F}Congratulazioni, questa era la risposta corretta\u{001F}verifica\u{001F}Premi Invio su un'area di rilascio per selezionarla, poi Invio su una scheda per posizionarla lì\u{001F}Area di rilascio\u{001F}vuota\u{001F}Lacuna\u{001F}mostra un indizio\u{001F}Risposta\u{001F}Controlla la risposta. La risposta è indicata come corretta o errata.\u{001F}Mostra la soluzione. Il quiz verrà contrassegnato come risolto.\u{001F}seleziona\u{001F}mostra la soluzione\u{001F}ordine crescente\u{001F}ordine discendente\u{001F}non ordinato\u{001F}Suono disattivato\u{001F}Suono attivo\u{001F}È necessario rispondere alla domanda prima dell'invio.\u{001F}È necessario rispondere a ogni riga prima dell'invio.\u{001F}Invia\u{001F}Grazie per il tuo feedback!\u{001F}Immetti del testo\u{001F}Aggiorna\u{001F}Tradurre con Google (sperimentale)\u{001F}di\u{001F}Pausa\u{001F}Posizione di riproduzione\u{001F}Preferisci la sintesi vocale del browser\u{001F}Riprendi\u{001F}Il tuo browser non supporta la sintesi vocale, provane un altro.\u{001F}Viene utilizzata la sintesi vocale integrata del browser."


i18nJa : String
i18nJa =
    "Aa\u{001F}ダイアログを閉じる\u{001F}検索をクリア\u{001F}エディター・スタイル\u{001F}フォントサイズ: \u{001E}\u{001F}脚注\u{001F}脚注一覧\u{001F}日本語\u{001F}新しいタブで開きます\u{001F}次へ\u{001F}結果なし\u{001F}1件の結果\u{001F}再生\u{001F}前へ\u{001F}パネルのサイズを変更\u{001F}結果\u{001F}検索\u{001F}小\u{001F}中\u{001F}大\u{001F}ナビゲーションをスキップ\u{001F}スライド\u{001F}スライドナビゲーション\u{001F}ステップ\u{001F}停止\u{001F}目次\u{001F}拡大\u{001F}青\u{001F}ライトモード\u{001F}色\u{001F}ダークモード\u{001F}デフォルト\u{001F}赤\u{001F}カラースキーム\u{001F}ターコイズ\u{001F}黄色\u{001F}棒グラフ\u{001F}ボックスプロット\u{001F}グラフ\u{001F}ファネルチャート\u{001F}関係グラフ\u{001F}ヒートマップ\u{001F}折れ線グラフ\u{001F}折れ線グラフ\u{001F}地図\u{001F}パラレル座標マップ\u{001F}円グラフ\u{001F}レーダーチャート\u{001F}サンキーダイアグラム\u{001F}散布図\u{001F}表\u{001F}ワードクラウド\u{001F}チャットを閉じる\u{001F}チャットメッセージ\u{001F}未読のチャットメッセージがあります\u{001F}チャットを開く\u{001F}メッセージを送信する\u{001F}未確認の送信者\u{001F}コードブロック\u{001F}クリップボードにコピーしました\u{001F}クリップボードにコピー\u{001F}コードエディター\u{001F}実行\u{001F}最初のバージョン\u{001F}最新のバージョン\u{001F}最大化\u{001F}最小化\u{001F}次のバージョン\u{001F}前のバージョン\u{001F}入力をリセット\u{001F}実行中\u{001F}ターミナルに送信\u{001F}ターミナル\u{001F}動画とアバターのコメントを非表示にする\u{001F}音程を変更\u{001F}音程\u{001F}再生速度を変更\u{001F}速度\u{001F}コメント\u{001F}色だけに頼らない\u{001F}エディターを開く\u{001F}情報\u{001F}設定\u{001F}共有\u{001F}共有方法...\u{001F}ツールチップ\u{001F}翻訳\u{001F}フルスクリーン表示\u{001F}フルスクリーンを終了する\u{001F}ホーム\u{001F}著者：\u{001F}著者：\u{001F}日付：\u{001F}メール：\u{001F}オフライン用にメディアをダウンロード\u{001F}失敗\u{001F}オフラインのメディア\u{001F}バージョン：\u{001F}プレゼンテーションモード\u{001F}ナビゲーションを隠す\u{001F}プレゼンテーション\u{001F}スライド\u{001F}教科書\u{001F}まだ翻訳されていません\u{001F}ウェブサイト用 QR コード\u{001F}QR コードを拡大\u{001F}QR コードのエンコード中にエラーが発生しました\u{001F}まだ正解ではありません\u{001F}解決済みの回答\u{001F}おめでとうございます、正解です\u{001F}確認\u{001F}ドロップ領域でEnterを押して選択し、次にカードでEnterを押してそこに配置します\u{001F}ドロップ領域\u{001F}空\u{001F}空欄\u{001F}ヒントを表示\u{001F}回答\u{001F}答えを確認してください。回答は正解または不正解でマークされます。\u{001F}解答を表示します。クイズは解決済みとマークされます。\u{001F}選択\u{001F}解答を表示\u{001F}昇順に並べ替え\u{001F}降順に並べ替え\u{001F}並べ替えなし\u{001F}音声オフ\u{001F}音声オン\u{001F}送信する前に質問に回答する必要があります。\u{001F}送信する前にすべての行に回答する必要があります。\u{001F}送信\u{001F}ご意見をお寄せいただきありがとうございます！\u{001F}テキストを入力してください...\u{001F}更新\u{001F}Google翻訳で翻訳する（実験的）\u{001F}/\u{001F}一時停止\u{001F}再生位置\u{001F}ブラウザのTTSを優先する\u{001F}再開\u{001F}このブラウザはテキスト読み上げに対応していません。他のブラウザをお試しください。\u{001F}ブラウザの内蔵テキスト読み上げエンジンを使用中"


i18nKa : String
i18nKa =
    "Aa\u{001F}დიალოგის დახურვა\u{001F}ძიების გასუფთავება\u{001F}რედაქტორის სტილი\u{001F}შრიფტის ზომა: \u{001E}\u{001F}სქოლიო\u{001F}სქოლიოები\u{001F}ქართული\u{001F}იხსნება ახალ ჩანართში\u{001F}შემდეგი\u{001F}შედეგები არ არის\u{001F}ერთი შედეგი\u{001F}დაკვრა\u{001F}წინა\u{001F}არეების ზომის შეცვლა\u{001F}შედეგები\u{001F}ძიება\u{001F}პატარა\u{001F}საშუალო\u{001F}დიდი\u{001F}ნავიგაციის გამოტოვება\u{001F}სლაიდი\u{001F}სლაიდების ნავიგაცია\u{001F}ნაბიჯი\u{001F}გაჩერება\u{001F}სარჩევი\u{001F}გადიდება\u{001F}ლურჯი\u{001F}ნათელი რეჟიმი\u{001F}ფერი\u{001F}მუქი რეჟიმი\u{001F}ნაგულისხმევი\u{001F}წითელი\u{001F}ფერთა სქემა\u{001F}ფირუზისფერი\u{001F}ყვითელი\u{001F}სვეტოვანი დიაგრამა\u{001F}ყუთოვანი დიაგრამა\u{001F}დიაგრამა\u{001F}ძაბრისებრი დიაგრამა\u{001F}კავშირების გრაფი\u{001F}სითბური რუქა\u{001F}ხაზოვანი დიაგრამა\u{001F}ხაზოვანი გრაფიკი\u{001F}რუქა\u{001F}პარალელური კოორდინატების რუქა\u{001F}წრიული დიაგრამა\u{001F}რადარული დიაგრამა\u{001F}სანკის დიაგრამა\u{001F}წერტილოვანი დიაგრამა\u{001F}ცხრილი\u{001F}სიტყვების ღრუბელი\u{001F}ჩატის დახურვა\u{001F}ჩატის შეტყობინება\u{001F}გაქვთ წაუკითხავი ჩატის შეტყობინებები\u{001F}ჩატის გახსნა\u{001F}შეტყობინების გაგზავნა\u{001F}დაუდასტურებელი გამგზავნი\u{001F}კოდის ბლოკი\u{001F}ბუფერში დაკოპირდა\u{001F}ბუფერში კოპირება\u{001F}კოდის რედაქტორი\u{001F}შესრულება\u{001F}პირველი ვერსია\u{001F}ბოლო ვერსია\u{001F}მაქსიმიზაცია\u{001F}მინიმიზაცია\u{001F}შემდეგი ვერსია\u{001F}წინა ვერსია\u{001F}შეყვანის გადაყენება\u{001F}მიმდინარეობს\u{001F}ტერმინალში გაგზავნა\u{001F}ტერმინალი\u{001F}ვიდეოსა და ავატარის კომენტარების დამალვა\u{001F}ტონის რეგულირება\u{001F}ტონი\u{001F}დაკვრის სიჩქარის რეგულირება\u{001F}სიჩქარე\u{001F}კომენტარები\u{001F}მხოლოდ ფერებზე არ დაყრდნობა\u{001F}რედაქტორის გახსნა\u{001F}ინფორმაცია\u{001F}პარამეტრები\u{001F}გაზიარება\u{001F}გაზიარება ...\u{001F}ამომხტარი მინიშნებები\u{001F}თარგმანები\u{001F}სრულ ეკრანზე გადასვლა\u{001F}სრული ეკრანიდან გამოსვლა\u{001F}მთავარი\u{001F}ავტორი: \u{001F}ავტორები: \u{001F}თარიღი: \u{001F}ელფოსტა: \u{001F}მედიის ჩამოტვირთვა ხაზგარეშე გამოყენებისთვის\u{001F}ვერ მოხერხდა\u{001F}მედია ხაზგარეშე\u{001F}ვერსია: \u{001F}პრეზენტაციის რეჟიმი\u{001F}ნავიგაციის დამალვა\u{001F}პრეზენტაცია\u{001F}სლაიდები\u{001F}სახელმძღვანელო\u{001F}ჯერ არ არის თარგმანი\u{001F}ვებგვერდისთვის QR კოდი\u{001F}QR კოდის გადიდება\u{001F}შეცდომა QR კოდში კოდირებისას\u{001F}სწორი პასუხი ჯერ არ არის მოწოდებული\u{001F}ამოხსნილი პასუხი\u{001F}გილოცავთ, ეს იყო სწორი პასუხი\u{001F}შეამოწმეთ\u{001F}დააჭირეთ Enter-ს ჩასაგდებ არეზე მის ასარჩევად, შემდეგ Enter-ს ბარათზე, რომ იქ მოათავსოთ\u{001F}ჩასაგდები არე\u{001F}ცარიელი\u{001F}გამოტოვებული ადგილი\u{001F}მინიშნების ჩვენება\u{001F}პასუხი\u{001F}შეამოწმეთ პასუხი. პასუხი მოინიშნება როგორც სწორი ან არასწორი.\u{001F}ამოხსნის ჩვენება. ქვიზი მოინიშნება როგორც ამოხსნილი.\u{001F}არჩევა\u{001F}ამოხსნის ჩვენება\u{001F}ზრდადობით დალაგება\u{001F}კლებადობით დალაგება\u{001F}არ არის დალაგებული\u{001F}ხმა გამორთული\u{001F}ხმა ჩართული\u{001F}გაგზავნამდე აუცილებელია კითხვაზე პასუხის გაცემა.\u{001F}გაგზავნამდე აუცილებელია ყველა სტრიქონზე პასუხის გაცემა.\u{001F}გაგზავნა\u{001F}გმადლობთ გამოხმაურებისთვის!\u{001F}შეიყვანეთ ტექსტი...\u{001F}განახლება\u{001F}თარგმნა Google-ის დახმარებით (ექსპერიმენტული)\u{001F}/\u{001F}პაუზა\u{001F}დაკვრის პოზიცია\u{001F}აირჩიეთ ბრაუზერის TTS\u{001F}გაგრძელება\u{001F}თქვენი ბრაუზერი მხარს არ უჭერს მეტყველების სინთეზს, სცადეთ სხვა.\u{001F}გამოიყენება ბრაუზერის ჩაშენებული მეტყველების სინთეზი."


i18nKo : String
i18nKo =
    "가\u{001F}대화 상자 닫기\u{001F}입력 내용 지우기\u{001F}편집기 스타일\u{001F}글꼴 크기: \u{001E}\u{001F}각주\u{001F}각주\u{001F}한국어\u{001F}새 탭에서 열림\u{001F}다음\u{001F}결과 없음\u{001F}결과 1개\u{001F}재생\u{001F}이전\u{001F}영역 크기 조절\u{001F}결과\u{001F}찾기\u{001F}작게\u{001F}보통\u{001F}크게\u{001F}탐색 건너뛰기\u{001F}슬라이드\u{001F}슬라이드 탐색\u{001F}단계\u{001F}정지\u{001F}목차\u{001F}확대\u{001F}파랑\u{001F}라이트 모드\u{001F}색상\u{001F}다크 모드\u{001F}기본\u{001F}빨강\u{001F}색상 스키마\u{001F}청록\u{001F}노랑\u{001F}막대 차트\u{001F}상자 그림\u{001F}차트\u{001F}퍼널 차트\u{001F}관계도\u{001F}히트 맵\u{001F}라인 차트\u{001F}선 그래프\u{001F}지도\u{001F}평행 좌표 그래프\u{001F}파이 차트\u{001F}레이더 차트\u{001F}생키 다이어그램\u{001F}산점도\u{001F}표\u{001F}워드 클라우드\u{001F}채팅 닫기\u{001F}채팅 메시지\u{001F}읽지 않은 채팅 메시지가 있습니다\u{001F}채팅 열기\u{001F}메시지 보내기\u{001F}확인되지 않은 보낸 사람\u{001F}코드 블록\u{001F}클립보드에 복사됨\u{001F}클립보드에 복사\u{001F}코드 편집기\u{001F}실행\u{001F}첫 버전\u{001F}최신 버전\u{001F}뷰 최대화\u{001F}뷰 최소화\u{001F}다음 버전\u{001F}이전 버전\u{001F}입력 초기화\u{001F}실행 중\u{001F}터미널로 보내기\u{001F}터미널\u{001F}비디오 및 아바타 해설 숨기기\u{001F}음높이 조절\u{001F}음높이\u{001F}재생 속도 조절\u{001F}속도\u{001F}해설\u{001F}색상에만 의존하지 않기\u{001F}편집기 열기\u{001F}정보\u{001F}설정\u{001F}공유\u{001F}공유하기\u{001F}도구 설명\u{001F}번역\u{001F}전체 화면으로\u{001F}전체 화면에서 나가기\u{001F}홈\u{001F}저자: \u{001F}저자: \u{001F}날짜: \u{001F}이메일: \u{001F}오프라인용 미디어 다운로드\u{001F}실패\u{001F}오프라인 미디어\u{001F}버전: \u{001F}프레젠테이션 모드\u{001F}탐색 숨기기\u{001F}프레젠테이션\u{001F}슬라이드\u{001F}교과서\u{001F}번역되지 않음\u{001F}웹 사이트용 QR 코드\u{001F}QR 코드 확대\u{001F}QR 코드를 만드는 도중 오류가 발생했습니다.\u{001F}정답이 아직 제시되지 않았습니다\u{001F}정답 공개됨\u{001F}축하합니다. 정답입니다\u{001F}확인\u{001F}드롭 영역에서 Enter 키를 눌러 선택한 다음, 카드에서 Enter 키를 눌러 그곳에 놓으세요\u{001F}드롭 영역\u{001F}비어 있음\u{001F}빈칸\u{001F}힌트 보기\u{001F}답\u{001F}답을 확인하세요. 정답 또는 오답으로 표시됩니다.\u{001F}정답을 보여 줍니다. 퀴즈가 해결된 것으로 표시됩니다.\u{001F}선택\u{001F}정답 보기\u{001F}오름차순 정렬\u{001F}내림차순 정렬\u{001F}정렬 안 됨\u{001F}소리 끔\u{001F}소리 켬\u{001F}제출하기 전에 질문에 답해야 합니다.\u{001F}제출하기 전에 모든 행에 답해야 합니다.\u{001F}제출\u{001F}의견을 보내 주셔서 감사합니다!\u{001F}내용을 입력해주세요.\u{001F}업데이트\u{001F}Google Translate로 번역하기 (실험적 기능)\u{001F}/\u{001F}일시 정지\u{001F}재생 위치\u{001F}브라우저 TTS 선호\u{001F}재개\u{001F}이 브라우저는 텍스트 음성 변환을 지원하지 않습니다. 다른 브라우저를 사용해 보세요.\u{001F}브라우저의 내부 텍스트 음성 변환 엔진을 사용합니다."


i18nLt : String
i18nLt =
    "Aa\u{001F}Užverti dialogo langą\u{001F}išvalyti paiešką\u{001F}Rengyklės stilius\u{001F}šrifto dydis: \u{001E}\u{001F}Išnaša\u{001F}Išnašos\u{001F}Lietuvių\u{001F}atsidaro naujame skirtuke\u{001F}kitas\u{001F}rezultatų nėra\u{001F}vienas rezultatas\u{001F}leisti\u{001F}ankstesnis\u{001F}Keisti sričių dydį\u{001F}rezultatai\u{001F}Ieškoti\u{001F}mažas\u{001F}vidutinis\u{001F}didelis\u{001F}Praleisti naršymą\u{001F}Skaidrė\u{001F}Skaidrių naršymas\u{001F}Žingsnis\u{001F}sustabdyti\u{001F}Turinys\u{001F}Padidinti\u{001F}Mėlyna\u{001F}Šviesus režimas\u{001F}Spalva\u{001F}Tamsus režimas\u{001F}Numatytoji\u{001F}Raudona\u{001F}Spalvų schema\u{001F}Turkio\u{001F}Geltona\u{001F}Stulpelinė diagrama\u{001F}Stačiakampė diagrama\u{001F}Diagrama\u{001F}Piltuvėlio diagrama\u{001F}Ryšių grafas\u{001F}Šilumos žemėlapis\u{001F}Linijinė diagrama\u{001F}Linijinis grafikas\u{001F}Žemėlapis\u{001F}Lygiagrečių koordinačių diagrama\u{001F}Skritulinė diagrama\u{001F}Radarinė diagrama\u{001F}Sankey diagrama\u{001F}Sklaidos diagrama\u{001F}Lentelė\u{001F}Žodžių debesis\u{001F}Užverti pokalbį\u{001F}Pokalbio žinutė\u{001F}Turi neskaitytų pokalbio žinučių\u{001F}Atverti pokalbį\u{001F}Siųsti žinutę\u{001F}Nepatvirtintas siuntėjas\u{001F}Kodo blokas\u{001F}nukopijuota į iškarpinę\u{001F}kopijuoti į iškarpinę\u{001F}Kodo rengyklė\u{001F}Vykdyti\u{001F}pirmoji versija\u{001F}paskutinė versija\u{001F}padidinti rodinį\u{001F}sumažinti rodinį\u{001F}kita versija\u{001F}ankstesnė versija\u{001F}atkurti pradinę įvestį\u{001F}vykdoma\u{001F}Siųsti į terminalą\u{001F}terminalas\u{001F}Slėpti vaizdo ir avataro komentarus\u{001F}Keisti balso aukštį\u{001F}Aukštis\u{001F}Keisti atkūrimo greitį\u{001F}Greitis\u{001F}Komentarai\u{001F}Nesiremti vien spalvomis\u{001F}Atverti rengyklę\u{001F}Informacija\u{001F}Nustatymai\u{001F}Bendrinti\u{001F}bendrinti per ...\u{001F}Paaiškinimai\u{001F}Vertimai\u{001F}Įjungti viso ekrano režimą\u{001F}Išjungti viso ekrano režimą\u{001F}Pradžia\u{001F}Autorius: \u{001F}Autoriai: \u{001F}Data: \u{001F}El. paštas: \u{001F}Atsisiųsti mediją naudoti neprisijungus\u{001F}nepavyko\u{001F}Medija neprisijungus\u{001F}Versija: \u{001F}Pristatymo režimas\u{001F}Slėpti naršymą\u{001F}Pristatymas\u{001F}Skaidrės\u{001F}Vadovėlis\u{001F}vertimo dar nėra\u{001F}Svetainės QR kodas\u{001F}Padidinti QR kodą\u{001F}Klaida kuriant QR kodą\u{001F}Teisingas atsakymas dar nepateiktas\u{001F}Atskleistas atsakymas\u{001F}Sveikiname, tai buvo teisingas atsakymas\u{001F}Tikrinti\u{001F}Paspausk Enter ant numetimo srities, kad ją pasirinktum, tada Enter ant kortelės, kad ją ten padėtum\u{001F}Numetimo sritis\u{001F}tuščia\u{001F}Spraga\u{001F}rodyti užuominą\u{001F}Atsakymas\u{001F}Patikrinti atsakymą. Atsakymas bus pažymėtas kaip teisingas arba neteisingas.\u{001F}Parodyti sprendimą. Užduotis bus pažymėta kaip išspręsta.\u{001F}pasirinkimas\u{001F}rodyti sprendimą\u{001F}rikiuoti didėjančiai\u{001F}rikiuoti mažėjančiai\u{001F}nesurikiuota\u{001F}Išjungti garsą\u{001F}Įjungti garsą\u{001F}Prieš pateikiant būtina atsakyti į klausimą.\u{001F}Prieš pateikiant būtina atsakyti į kiekvieną eilutę.\u{001F}Pateikti\u{001F}Dėkojame už atsiliepimą!\u{001F}Įvesk tekstą...\u{001F}Atnaujinti\u{001F}Versti su „Google“ (eksperimentinė funkcija)\u{001F}iš\u{001F}Pristabdyti\u{001F}Atkūrimo padėtis\u{001F}Teikti pirmenybę naršyklės kalbos sintezei\u{001F}Tęsti\u{001F}Tavo naršyklė nepalaiko kalbos sintezės. Išbandyk kitą.\u{001F}Naudojama naršyklėje integruota kalbos sintezė."


i18nLv : String
i18nLv =
    "Aa\u{001F}Aizvērt dialoglodziņu\u{001F}notīrīt meklēšanu\u{001F}Redaktora stils\u{001F}fonta lielums: \u{001E}\u{001F}Vēre\u{001F}Vēres\u{001F}Latviešu\u{001F}atveras jaunā cilnē\u{001F}nākamais\u{001F}nav rezultātu\u{001F}viens rezultāts\u{001F}atskaņot\u{001F}iepriekšējais\u{001F}Mainīt apgabalu izmēru\u{001F}rezultāti\u{001F}Meklēt\u{001F}mazs\u{001F}vidējs\u{001F}liels\u{001F}Izlaist navigāciju\u{001F}Slaids\u{001F}Slaidu navigācija\u{001F}Solis\u{001F}apturēt\u{001F}Satura rādītājs\u{001F}Palielināt\u{001F}Zila\u{001F}Gaišais režīms\u{001F}Krāsa\u{001F}Tumšais režīms\u{001F}Noklusējuma\u{001F}Sarkana\u{001F}Krāsu shēma\u{001F}Tirkīza\u{001F}Dzeltena\u{001F}Stabiņu diagramma\u{001F}Kastveida diagramma\u{001F}Diagramma\u{001F}Piltuves diagramma\u{001F}Saistību grafs\u{001F}Siltuma karte\u{001F}Līniju diagramma\u{001F}Līniju grafiks\u{001F}Karte\u{001F}Paralēlo koordinātu diagramma\u{001F}Sektoru diagramma\u{001F}Radara diagramma\u{001F}Sankey diagramma\u{001F}Izkliedes diagramma\u{001F}Tabula\u{001F}Vārdu mākonis\u{001F}Aizvērt tērzēšanu\u{001F}Tērzēšanas ziņojums\u{001F}Tev ir nelasīti tērzēšanas ziņojumi\u{001F}Atvērt tērzēšanu\u{001F}Sūtīt ziņojumu\u{001F}Nepārbaudīts sūtītājs\u{001F}Koda bloks\u{001F}nokopēts starpliktuvē\u{001F}kopēt starpliktuvē\u{001F}Koda redaktors\u{001F}Izpildīt\u{001F}pirmā versija\u{001F}pēdējā versija\u{001F}maksimizēt skatu\u{001F}minimizēt skatu\u{001F}nākamā versija\u{001F}iepriekšējā versija\u{001F}atiestatīt ievadi\u{001F}tiek izpildīts\u{001F}Sūtīt uz termināli\u{001F}terminālis\u{001F}Paslēpt video un avatāra komentārus\u{001F}Pielāgot balss augstumu\u{001F}Augstums\u{001F}Pielāgot atskaņošanas ātrumu\u{001F}Ātrums\u{001F}Komentāri\u{001F}Nepaļauties tikai uz krāsām\u{001F}Atvērt redaktoru\u{001F}Informācija\u{001F}Iestatījumi\u{001F}Kopīgot\u{001F}kopīgot, izmantojot ...\u{001F}Rīku padomi\u{001F}Tulkojumi\u{001F}Ieslēgt pilnekrāna režīmu\u{001F}Iziet no pilnekrāna režīma\u{001F}Sākums\u{001F}Autors: \u{001F}Autori: \u{001F}Datums: \u{001F}E-pasts: \u{001F}Lejupielādēt multividi lietošanai bezsaistē\u{001F}neizdevās\u{001F}Multivide bezsaistē\u{001F}Versija: \u{001F}Prezentācijas režīms\u{001F}Paslēpt navigāciju\u{001F}Prezentācija\u{001F}Slaidi\u{001F}Mācību grāmata\u{001F}tulkojums vēl nav pieejams\u{001F}Vietnes QR kods\u{001F}Palielināt QR kodu\u{001F}Kļūda, veidojot QR kodu\u{001F}Pareizā atbilde vēl nav sniegta\u{001F}Atklātā atbilde\u{001F}Apsveicam, tā bija pareizā atbilde\u{001F}Pārbaudīt\u{001F}Nospied Enter uz nomešanas zonas, lai to izvēlētos, tad Enter uz kartītes, lai to tur novietotu\u{001F}Nomešanas zona\u{001F}tukša\u{001F}Aizpildāmā vieta\u{001F}rādīt norādi\u{001F}Atbilde\u{001F}Pārbaudīt atbildi. Atbilde tiks atzīmēta kā pareiza vai nepareiza.\u{001F}Parādīt risinājumu. Uzdevums tiks atzīmēts kā atrisināts.\u{001F}izvēle\u{001F}rādīt risinājumu\u{001F}kārtot augošā secībā\u{001F}kārtot dilstošā secībā\u{001F}nav sakārtots\u{001F}Izslēgt skaņu\u{001F}Ieslēgt skaņu\u{001F}Pirms iesniegšanas jāatbild uz jautājumu.\u{001F}Pirms iesniegšanas jāatbild uz katru rindu.\u{001F}Iesniegt\u{001F}Paldies par atsauksmi!\u{001F}Ievadi tekstu...\u{001F}Atjaunināt\u{001F}Tulkot ar Google (eksperimentāli)\u{001F}no\u{001F}Pauzēt\u{001F}Atskaņošanas pozīcija\u{001F}Dot priekšroku pārlūkprogrammas runas sintēzei\u{001F}Turpināt\u{001F}Tava pārlūkprogramma neatbalsta runas sintēzi. Izmēģini citu.\u{001F}Tiek izmantota pārlūkprogrammā iebūvētā runas sintēze."


i18nNb : String
i18nNb =
    "Aa\u{001F}Lukk dialogen\u{001F}tøm søk\u{001F}Editorstil\u{001F}skriftstørrelse: \u{001E}\u{001F}Fotnote\u{001F}Fotnoter\u{001F}Norsk bokmål\u{001F}åpnes i en ny fane\u{001F}neste\u{001F}ingen resultater\u{001F}ett resultat\u{001F}spill av\u{001F}forrige\u{001F}Endre størrelse på panelene\u{001F}resultater\u{001F}Søk\u{001F}liten\u{001F}middels\u{001F}stor\u{001F}Hopp over navigasjonen\u{001F}Lysbilde\u{001F}Lysbildenavigasjon\u{001F}Trinn\u{001F}stopp\u{001F}Innholdsfortegnelse\u{001F}Forstørr\u{001F}Blå\u{001F}Lys modus\u{001F}Farge\u{001F}Mørk modus\u{001F}Standard\u{001F}Rød\u{001F}Fargevalg\u{001F}Turkis\u{001F}Gul\u{001F}Stolpediagram\u{001F}Boksplott\u{001F}Diagram\u{001F}Traktdiagram\u{001F}Relasjonsgraf\u{001F}Varmekart\u{001F}Linjediagram\u{001F}Linjegraf\u{001F}Kart\u{001F}Diagram med parallelle koordinater\u{001F}Sektordiagram\u{001F}Radardiagram\u{001F}Sankey-diagram\u{001F}Spredningsdiagram\u{001F}Tabell\u{001F}Ordsky\u{001F}Lukk chatten\u{001F}Chatmelding\u{001F}Du har uleste chatmeldinger\u{001F}Åpne chatten\u{001F}Send melding\u{001F}Ubekreftet avsender\u{001F}Kodeblokk\u{001F}kopiert til utklippstavlen\u{001F}kopier til utklippstavlen\u{001F}Kodeeditor\u{001F}Kjør\u{001F}første versjon\u{001F}siste versjon\u{001F}maksimer visning\u{001F}minimer visning\u{001F}neste versjon\u{001F}forrige versjon\u{001F}tilbakestill inndata\u{001F}kjører\u{001F}Send til terminalen\u{001F}terminal\u{001F}Skjul video- og avatarkommentarer\u{001F}Juster tonehøyde\u{001F}Tone\u{001F}Juster avspillingshastighet\u{001F}Tempo\u{001F}Kommentarer\u{001F}Ikke stol på farger alene\u{001F}Åpne editoren\u{001F}Informasjon\u{001F}Innstillinger\u{001F}Del\u{001F}del via ...\u{001F}Verktøytips\u{001F}Oversettelser\u{001F}Åpne fullskjerm\u{001F}Avslutt fullskjerm\u{001F}Hjem\u{001F}Forfatter: \u{001F}Forfattere: \u{001F}Dato: \u{001F}E-post: \u{001F}Last ned medier for frakoblet bruk\u{001F}mislyktes\u{001F}Medier frakoblet\u{001F}Versjon: \u{001F}Presentasjonsmodus\u{001F}Skjul navigasjon\u{001F}Presentasjon\u{001F}Lysbilder\u{001F}Lærebok\u{001F}ingen oversettelse ennå\u{001F}QR-kode for nettstedet\u{001F}Forstørr QR-koden\u{001F}Feil ved oppretting av QR-kode\u{001F}Riktig svar er ikke gitt ennå\u{001F}Avslørt svar\u{001F}Gratulerer, det var riktig svar\u{001F}Kontroller\u{001F}Trykk Enter på en slippsone for å velge den, og deretter Enter på et kort for å plassere det der\u{001F}Slippsone\u{001F}tom\u{001F}Luke\u{001F}vis hint\u{001F}Svar\u{001F}Kontroller svaret. Svaret markeres som riktig eller feil.\u{001F}Vis løsningen. Oppgaven markeres som løst.\u{001F}valg\u{001F}vis løsning\u{001F}sorter stigende\u{001F}sorter synkende\u{001F}ikke sortert\u{001F}Lyd av\u{001F}Lyd på\u{001F}Spørsmålet må besvares før innsending.\u{001F}Alle radene må besvares før innsending.\u{001F}Send\u{001F}Takk for tilbakemeldingen din!\u{001F}Skriv inn tekst...\u{001F}Oppdater\u{001F}Oversett med Google (eksperimentelt)\u{001F}av\u{001F}Pause\u{001F}Avspillingsposisjon\u{001F}Foretrekk nettleserens talesyntese\u{001F}Fortsett\u{001F}Nettleseren din støtter ikke talesyntese. Prøv en annen.\u{001F}Nettleserens innebygde talesyntese brukes."


i18nNl : String
i18nNl =
    "Aa\u{001F}Dialoogvenster sluiten\u{001F}Zoekopdracht wissen\u{001F}editor-stijl\u{001F}Lettergrootte: \u{001E}\u{001F}Voetnoot\u{001F}Voetnoten\u{001F}Nederlands\u{001F}opent in een nieuw tabblad\u{001F}verder\u{001F}Geen resultaten\u{001F}een resultaat\u{001F}afspelen\u{001F}terug\u{001F}Grootte van deelvensters wijzigen\u{001F}Resultaten\u{001F}Zoeken\u{001F}klein\u{001F}medium\u{001F}groot\u{001F}Navigatie overslaan\u{001F}Dia\u{001F}Dianavigatie\u{001F}Stap\u{001F}stoppen\u{001F}Inhoudsopgave\u{001F}Vergroten\u{001F}blauw\u{001F}lichte modus\u{001F}kleur\u{001F}donkere modus\u{001F}standaard\u{001F}rood\u{001F}Kleurenschema\u{001F}turkoois\u{001F}geel\u{001F}Staafdiagram\u{001F}Boxplot\u{001F}Grafiek\u{001F}Trechterdiagram\u{001F}Relatiegrafiek\u{001F}Heatmap\u{001F}Lijndiagram\u{001F}Lijngrafiek\u{001F}Kaart\u{001F}Diagram met parallelle coördinaten\u{001F}Cirkeldiagram\u{001F}Radardiagram\u{001F}Sankeydiagram\u{001F}Spreidingsdiagram\u{001F}Tabel\u{001F}Woordwolk\u{001F}Chat sluiten\u{001F}Chatbericht\u{001F}Je hebt ongelezen chatberichten\u{001F}Chat openen\u{001F}Bericht versturen\u{001F}Niet-geverifieerde afzender\u{001F}Codeblok\u{001F}gekopieerd naar klembord\u{001F}kopiëren naar klembord\u{001F}Code-editor\u{001F}uitvoeren\u{001F}eerste versie\u{001F}laatste versie\u{001F}weergave maximaliseren\u{001F}weergave verkleinen\u{001F}een versie vooruit\u{001F}een versie terug\u{001F}invoer herstellen\u{001F}wordt uitgevoerd\u{001F}Naar terminal sturen\u{001F}terminal\u{001F}Video- en avatarcommentaar verbergen\u{001F}Toonhoogte aanpassen\u{001F}Toon\u{001F}Afspeelsnelheid aanpassen\u{001F}Tempo\u{001F}Commentaar\u{001F}Niet alleen op kleur vertrouwen\u{001F}Editor openen\u{001F}Informatie\u{001F}Instellingen\u{001F}Delen\u{001F}deel via ...\u{001F}Tooltips\u{001F}Vertalingen\u{001F}Volledig scherm\u{001F}Volledig scherm verlaten\u{001F}Start\u{001F}Auteur: \u{001F}Auteurs: \u{001F}Datum: \u{001F}E-mail: \u{001F}Media downloaden voor offline gebruik\u{001F}mislukt\u{001F}Media offline\u{001F}Versie: \u{001F}Presentatiemodus\u{001F}Navigatie verbergen\u{001F}Presentatie\u{001F}Dia's\u{001F}Studieboek\u{001F}nog geen vertaling beschikbaar\u{001F}QR-code voor website\u{001F}QR-code vergroten\u{001F}Fout bij het coderen naar QR-code\u{001F}Het juiste antwoord is nog niet gegeven\u{001F}Opgelost antwoord\u{001F}Gefeliciteerd, dat was het juiste antwoord\u{001F}Controleren\u{001F}Druk op Enter bij een neerzetzone om die te selecteren en daarna op Enter bij een kaart om die daar te plaatsen\u{001F}Neerzetzone\u{001F}leeg\u{001F}Invulveld\u{001F}toon hint\u{001F}Antwoord\u{001F}Controleer het antwoord. Het antwoord wordt gemarkeerd als goed of fout.\u{001F}Laat de oplossing zien. De quiz wordt gemarkeerd als opgelost.\u{001F}selectie\u{001F}toon oplossing\u{001F}oplopend sorteren\u{001F}aflopend sorteren\u{001F}niet gesorteerd\u{001F}Geluid uit\u{001F}Geluid aan\u{001F}De vraag moet vóór het verzenden worden beantwoord.\u{001F}Elke rij moet vóór het verzenden worden beantwoord.\u{001F}Verzenden\u{001F}Bedankt voor je feedback!\u{001F}Tekstinvoer ...\u{001F}Bijwerken\u{001F}Vertalen met Google (experimenteel)\u{001F}van\u{001F}Pauzeren\u{001F}Afspeelpositie\u{001F}Voorkeur voor browser-TTS\u{001F}Hervatten\u{001F}Je browser ondersteunt geen tekst-naar-spraak, probeer een andere.\u{001F}De interne tekst-naar-spraak-engine van de browser wordt gebruikt."


i18nPa : String
i18nPa =
    "ਅਆ\u{001F}ਡਾਇਲਾਗ ਬੰਦ ਕਰੋ\u{001F}ਖੋਜ ਹਟਾਓ\u{001F}ਸੰਪਾਦਕ ਸਟਾਈਲ\u{001F}ਫੋਂਟ ਆਕਾਰ: \u{001E}\u{001F}ਫੁਟਨੋਟ\u{001F}ਫੁਟਨੋਟ\u{001F}ਪੰਜਾਬੀ\u{001F}ਨਵੀਂ ਟੈਬ ਵਿੱਚ ਖੁੱਲ੍ਹਦਾ ਹੈ\u{001F}ਅੱਗੇ\u{001F}ਕੋਈ ਨਤੀਜਾ ਨਹੀਂ\u{001F}ਇੱਕ ਨਤੀਜਾ\u{001F}ਚਲਾਓ\u{001F}ਪਿੱਛੇ\u{001F}ਭਾਗਾਂ ਦਾ ਆਕਾਰ ਬਦਲੋ\u{001F}ਨਤੀਜੇ\u{001F}ਖੋਜ\u{001F}ਛੋਟਾ\u{001F}ਦਰਮਿਆਨਾ\u{001F}ਵੱਡਾ\u{001F}ਨੈਵੀਗੇਸ਼ਨ ਛੱਡੋ\u{001F}ਸਲਾਈਡ\u{001F}ਸਲਾਈਡ ਨੈਵੀਗੇਸ਼ਨ\u{001F}ਕਦਮ\u{001F}ਬੰਦ ਕਰੋ\u{001F}ਵਿਸ਼ਾ ਸੂਚੀ\u{001F}ਵੱਡਾ ਕਰੋ\u{001F}ਨੀਲਾ\u{001F}ਲਾਈਟ ਮੋਡ\u{001F}ਰੰਗ\u{001F}ਡਾਰਕ ਮੋਡ\u{001F}ਮੂਲ\u{001F}ਲਾਲ\u{001F}ਰੰਗ ਸਕੀਮ\u{001F}ਫੀਰੋਜ਼ੀ\u{001F}ਪੀਲਾ\u{001F}ਬਾਰ ਚਾਰਟ\u{001F}ਬਾਕਸਪਲਾਟ\u{001F}ਚਾਰਟ\u{001F}ਫਨਲ ਚਾਰਟ\u{001F}ਸੰਬੰਧ ਗ੍ਰਾਫ਼\u{001F}ਹੀਟਮੈਪ\u{001F}ਰੇਖਾ ਚਾਰਟ\u{001F}ਰੇਖਾ ਗ੍ਰਾਫ਼\u{001F}ਨਕਸ਼ਾ\u{001F}ਸਮਾਂਤਰ ਕੋਆਰਡੀਨੇਟ ਚਾਰਟ\u{001F}ਪਾਈ ਚਾਰਟ\u{001F}ਰਾਡਾਰ ਚਾਰਟ\u{001F}ਸੈਂਕੀ ਡਾਇਗ੍ਰਾਮ\u{001F}ਸਕੈਟਰ ਪਲਾਟ\u{001F}ਸਾਰਣੀ\u{001F}ਸ਼ਬਦ ਬੱਦਲ\u{001F}ਚੈਟ ਬੰਦ ਕਰੋ\u{001F}ਚੈਟ ਸੁਨੇਹਾ\u{001F}ਤੁਹਾਡੇ ਕੋਲ ਨਾ-ਪੜ੍ਹੇ ਚੈਟ ਸੁਨੇਹੇ ਹਨ\u{001F}ਚੈਟ ਖੋਲ੍ਹੋ\u{001F}ਸੁਨੇਹਾ ਭੇਜੋ\u{001F}ਅਪ੍ਰਮਾਣਿਤ ਭੇਜਣ ਵਾਲਾ\u{001F}ਕੋਡ ਬਲਾਕ\u{001F}ਕਲਿੱਪਬੋਰਡ 'ਤੇ ਕਾਪੀ ਹੋ ਗਿਆ\u{001F}ਕਲਿੱਪਬੋਰਡ 'ਤੇ ਕਾਪੀ\u{001F}ਕੋਡ ਸੰਪਾਦਕ\u{001F}ਚਲਾਓ\u{001F}ਪਹਿਲਾ ਵਰਜਨ\u{001F}ਆਖਰੀ ਵਰਜਨ\u{001F}ਝਲਕ ਵੱਡੀ ਕਰੋ\u{001F}ਝਲਕ ਛੋਟੀ ਕਰੋ\u{001F}ਅਗਲਾ ਵਰਜਨ\u{001F}ਪਿਛਲਾ ਵਰਜਨ\u{001F}ਇਨਪੁਟ ਰੀਸੈੱਟ ਕਰੋ\u{001F}ਚੱਲ ਰਿਹਾ ਹੈ\u{001F}ਟਰਮੀਨਲ ਨੂੰ ਭੇਜੋ\u{001F}ਟਰਮੀਨਲ\u{001F}ਵੀਡੀਓ ਅਤੇ ਅਵਤਾਰ ਟਿੱਪਣੀਆਂ ਛੁਪਾਓ\u{001F}ਸੁਰ ਸੰਰਚਨਾ\u{001F}ਸੁਰ\u{001F}ਪਲੇਬੈਕ ਗਤੀ ਸੰਰਚਨਾ\u{001F}ਗਤੀ\u{001F}ਟਿੱਪਣੀਆਂ\u{001F}ਸਿਰਫ਼ ਰੰਗਾਂ 'ਤੇ ਨਿਰਭਰ ਨਾ ਕਰੋ\u{001F}ਸੰਪਾਦਕ ਖੋਲ੍ਹੋ\u{001F}ਜਾਣਕਾਰੀ\u{001F}ਸੈਟਿੰਗਾਂ\u{001F}ਸਾਂਝਾ ਕਰੋ\u{001F}ਇਸ ਰਾਹੀਂ ਸਾਂਝਾ ਕਰੋ ...\u{001F}ਟੂਲਟਿੱਪ\u{001F}ਅਨੁਵਾਦ\u{001F}ਪੂਰੀ ਸਕ੍ਰੀਨ\u{001F}ਪੂਰੀ ਸਕ੍ਰੀਨ ਤੋਂ ਬਾਹਰ\u{001F}ਮੁੱਖ ਪੰਨਾ\u{001F}ਲੇਖਕ: \u{001F}ਲੇਖਕ: \u{001F}ਮਿਤੀ: \u{001F}ਈਮੇਲ: \u{001F}ਔਫਲਾਈਨ ਵਰਤੋਂ ਲਈ ਮੀਡੀਆ ਡਾਊਨਲੋਡ ਕਰੋ\u{001F}ਅਸਫਲ\u{001F}ਮੀਡੀਆ ਔਫਲਾਈਨ\u{001F}ਵਰਜਨ: \u{001F}ਪ੍ਰਸਤੁਤੀ ਮੋਡ\u{001F}ਨੈਵੀਗੇਸ਼ਨ ਲੁਕਾਓ\u{001F}ਪ੍ਰਸਤੁਤੀ\u{001F}ਸਲਾਈਡ\u{001F}ਟੈਕਸਟਬੁੱਕ\u{001F}ਅਜੇ ਅਨੁਵਾਦ ਨਹੀਂ ਹੈ\u{001F}ਵੈੱਬਸਾਈਟ ਲਈ QR ਕੋਡ\u{001F}QR ਕੋਡ ਵੱਡਾ ਕਰੋ\u{001F}QR ਕੋਡ ਨੂੰ ਏਨਕੋਡ ਕਰਨ ਦੌਰਾਨ ਗਲਤੀ ਆਈ ਹੈ\u{001F}ਸਹੀ ਜਵਾਬ ਹਾਲੇ ਨਹੀਂ ਦਿੱਤਾ ਗਿਆ ਹੈ।\u{001F}ਹੱਲ ਕੀਤਾ ਗਿਆ ਜਵਾਬ\u{001F}ਵਧਾਈ ਹੋ, ਇਹ ਸਹੀ ਜਵਾਬ ਸੀ।\u{001F}ਜਾਂਚ ਕਰੋ\u{001F}ਰੱਖਣ ਵਾਲੇ ਖੇਤਰ ਨੂੰ ਚੁਣਨ ਲਈ ਉਸ 'ਤੇ Enter ਦਬਾਓ, ਫਿਰ ਕਾਰਡ ਨੂੰ ਉੱਥੇ ਰੱਖਣ ਲਈ ਕਾਰਡ 'ਤੇ Enter ਦਬਾਓ\u{001F}ਰੱਖਣ ਵਾਲਾ ਖੇਤਰ\u{001F}ਖਾਲੀ\u{001F}ਖਾਲੀ ਥਾਂ\u{001F}ਸੰਕੇਤ ਦਿਖਾਓ\u{001F}ਜਵਾਬ\u{001F}ਜਵਾਬ ਦੀ ਜਾਂਚ ਕਰੋ। ਜਵਾਬ ਨੂੰ ਸਹੀ ਜਾਂ ਗਲਤ ਵਜੋਂ ਨਿਸ਼ਾਨਬੱਧ ਕੀਤਾ ਜਾਵੇਗਾ।\u{001F}ਹੱਲ ਦਿਖਾਓ। ਕਵਿਜ਼ ਨੂੰ ਹੱਲ ਕੀਤਾ ਵਜੋਂ ਨਿਸ਼ਾਨਬੱਧ ਕੀਤਾ ਜਾਵੇਗਾ।\u{001F}ਚੋਣ\u{001F}ਹੱਲ ਦਿਖਾਓ\u{001F}ਵਧਦੇ ਕ੍ਰਮ ਵਿੱਚ ਕ੍ਰਮਬੱਧ ਕਰੋ\u{001F}ਘਟਦੇ ਕ੍ਰਮ ਵਿੱਚ ਕ੍ਰਮਬੱਧ ਕਰੋ\u{001F}ਕ੍ਰਮਬੱਧ ਨਹੀਂ\u{001F}ਆਵਾਜ਼ ਬੰਦ\u{001F}ਆਵਾਜ਼ ਚਾਲੂ\u{001F}ਜਮ੍ਹਾਂ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਸਵਾਲ ਦਾ ਜਵਾਬ ਦਿੱਤਾ ਜਾਣਾ ਲਾਜ਼ਮੀ ਹੈ।\u{001F}ਜਮ੍ਹਾਂ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਹਰ ਕਤਾਰ ਦਾ ਜਵਾਬ ਦਿੱਤਾ ਜਾਣਾ ਲਾਜ਼ਮੀ ਹੈ।\u{001F}ਜਮ੍ਹਾਂ ਕਰੋ\u{001F}ਤੁਹਾਡੀ ਪ੍ਰਤੀਕਿਰਿਆ ਲਈ ਧੰਨਵਾਦ!\u{001F}ਕੁਝ ਟੈਕਸਟ ਦਿਓ...\u{001F}ਅੱਪਡੇਟ ਕਰੋ\u{001F}ਗੂਗਲ ਨਾਲ ਅਨੁਵਾਦ ਕਰੋ (ਪ੍ਰਯੋਗਾਤਮਕ)\u{001F}/\u{001F}ਵਿਰਾਮ\u{001F}ਪਲੇਬੈਕ ਸਥਿਤੀ\u{001F}ਬਰਾਊਜ਼ਰ TTS ਨੂੰ ਤਰਜੀਹ ਦਿਓ\u{001F}ਜਾਰੀ ਰੱਖੋ\u{001F}ਤੁਹਾਡਾ ਬਰਾਊਜ਼ਰ ਟੈਕਸਟ-ਟੁ-ਸਪੀਚ ਦਾ ਸਮਰਥਨ ਨਹੀਂ ਕਰਦਾ, ਕੋਈ ਹੋਰ ਬਰਾਊਜ਼ਰ ਵਰਤੋ।\u{001F}ਬਰਾਊਜ਼ਰ ਦੇ ਅੰਦਰੂਨੀ ਟੈਕਸਟ-ਟੁ-ਸਪੀਚ ਇੰਜਨ ਦੀ ਵਰਤੋਂ ਕੀਤੀ ਜਾ ਰਹੀ ਹੈ।"


i18nPl : String
i18nPl =
    "Aa\u{001F}Zamknij okno dialogowe\u{001F}wyczyść wyszukiwanie\u{001F}Styl edytora\u{001F}rozmiar czcionki: \u{001E}\u{001F}Przypis\u{001F}Przypisy\u{001F}Polski\u{001F}otwiera się w nowej karcie\u{001F}dalej\u{001F}brak wyników\u{001F}jeden wynik\u{001F}odtwórz\u{001F}wstecz\u{001F}Zmień rozmiar paneli\u{001F}wyniki\u{001F}Szukaj\u{001F}mały\u{001F}średni\u{001F}duży\u{001F}Pomiń nawigację\u{001F}Slajd\u{001F}Nawigacja slajdów\u{001F}Krok\u{001F}zatrzymaj\u{001F}Spis treści\u{001F}Powiększ\u{001F}Niebieski\u{001F}Tryb jasny\u{001F}Kolor\u{001F}Tryb ciemny\u{001F}Domyślny\u{001F}Czerwony\u{001F}Schemat kolorów\u{001F}Turkusowy\u{001F}Żółty\u{001F}Wykres słupkowy\u{001F}Wykres pudełkowy\u{001F}Wykres\u{001F}Wykres lejkowy\u{001F}Graf relacji\u{001F}Mapa cieplna\u{001F}Wykres liniowy\u{001F}Wykres liniowy\u{001F}Mapa\u{001F}Wykres współrzędnych równoległych\u{001F}Wykres kołowy\u{001F}Wykres radarowy\u{001F}Diagram Sankeya\u{001F}Wykres punktowy\u{001F}Tabela\u{001F}Chmura słów\u{001F}Zamknij czat\u{001F}Wiadomość czatu\u{001F}Masz nieprzeczytane wiadomości na czacie\u{001F}Otwórz czat\u{001F}Wyślij wiadomość\u{001F}Niezweryfikowany nadawca\u{001F}Blok kodu\u{001F}skopiowano do schowka\u{001F}kopiuj do schowka\u{001F}Edytor kodu\u{001F}Uruchom\u{001F}pierwsza wersja\u{001F}ostatnia wersja\u{001F}maksymalizuj widok\u{001F}minimalizuj widok\u{001F}następna wersja\u{001F}poprzednia wersja\u{001F}resetuj dane wejściowe\u{001F}działa\u{001F}Wyślij do terminala\u{001F}terminal\u{001F}Ukryj komentarze wideo i awatara\u{001F}Dostosuj wysokość głosu\u{001F}Wysokość\u{001F}Dostosuj prędkość odtwarzania\u{001F}Tempo\u{001F}Komentarze\u{001F}Nie polegaj tylko na kolorze\u{001F}Otwórz edytor\u{001F}Informacje\u{001F}Ustawienia\u{001F}Udostępnij\u{001F}udostępnij przez ...\u{001F}Podpowiedzi\u{001F}Tłumaczenia\u{001F}Włącz pełny ekran\u{001F}Wyłącz pełny ekran\u{001F}Strona główna\u{001F}Autor: \u{001F}Autorzy: \u{001F}Data: \u{001F}E-mail: \u{001F}Pobierz multimedia do użytku offline\u{001F}nieudane\u{001F}Multimedia offline\u{001F}Wersja: \u{001F}Tryb prezentacji\u{001F}Ukryj nawigację\u{001F}Prezentacja\u{001F}Slajdy\u{001F}Podręcznik\u{001F}brak tłumaczenia\u{001F}Kod QR strony internetowej\u{001F}Powiększ kod QR\u{001F}Błąd podczas tworzenia kodu QR\u{001F}Nie podano jeszcze poprawnej odpowiedzi\u{001F}Ujawniona odpowiedź\u{001F}Gratulacje, to była poprawna odpowiedź\u{001F}Sprawdź\u{001F}Naciśnij Enter na polu upuszczania, aby je wybrać, a następnie Enter na karcie, aby ją tam umieścić\u{001F}Pole upuszczania\u{001F}puste\u{001F}Luka\u{001F}pokaż wskazówkę\u{001F}Odpowiedź\u{001F}Sprawdź odpowiedź. Odpowiedź zostanie oznaczona jako poprawna lub niepoprawna.\u{001F}Pokaż rozwiązanie. Zadanie zostanie oznaczone jako rozwiązane.\u{001F}wybór\u{001F}pokaż rozwiązanie\u{001F}sortuj rosnąco\u{001F}sortuj malejąco\u{001F}nieposortowane\u{001F}Wyłącz dźwięk\u{001F}Włącz dźwięk\u{001F}Przed wysłaniem należy odpowiedzieć na pytanie.\u{001F}Przed wysłaniem należy udzielić odpowiedzi w każdym wierszu.\u{001F}Wyślij\u{001F}Dziękujemy za opinię!\u{001F}Wpisz tekst...\u{001F}Aktualizuj\u{001F}Przetłumacz za pomocą Google (eksperymentalne)\u{001F}z\u{001F}Wstrzymaj\u{001F}Pozycja odtwarzania\u{001F}Preferuj syntezę mowy przeglądarki\u{001F}Wznów\u{001F}Twoja przeglądarka nie obsługuje syntezy mowy. Wypróbuj inną.\u{001F}Używana jest wbudowana synteza mowy przeglądarki."


i18nPt : String
i18nPt =
    "Aa\u{001F}Fechar diálogo\u{001F}limpar busca\u{001F}Estilo do editor\u{001F}tamanho da fonte: \u{001E}\u{001F}Nota de rodapé\u{001F}Notas de rodapé\u{001F}Português\u{001F}abre em uma nova aba\u{001F}próximo\u{001F}sem resultados\u{001F}um resultado\u{001F}reproduzir\u{001F}anterior\u{001F}Redimensionar painéis\u{001F}resultados\u{001F}Buscar\u{001F}pequeno\u{001F}médio\u{001F}grande\u{001F}Pular navegação\u{001F}Slide\u{001F}Navegação dos slides\u{001F}Passo\u{001F}parar\u{001F}Sumário\u{001F}Ampliar\u{001F}Azul\u{001F}Modo claro\u{001F}Cor\u{001F}Modo escuro\u{001F}Padrão\u{001F}Vermelho\u{001F}Esquema de cores\u{001F}Turquesa\u{001F}Amarelo\u{001F}Gráfico de barras\u{001F}Diagrama de caixa\u{001F}Gráfico\u{001F}Gráfico de funil\u{001F}Gráfico de relacionamento\u{001F}Mapa de calor\u{001F}Gráfico de linhas\u{001F}Gráfico de linhas\u{001F}Mapa\u{001F}Mapa de coordenadas paralelas\u{001F}Gráfico de pizza\u{001F}Gráfico de radar\u{001F}Diagrama de Sankey\u{001F}Gráfico de dispersão\u{001F}Tabela\u{001F}Nuvem de palavras\u{001F}Fechar chat\u{001F}Mensagem de chat\u{001F}Você tem mensagens de chat não lidas\u{001F}Abrir chat\u{001F}Enviar mensagem\u{001F}Remetente não verificado\u{001F}Bloco de código\u{001F}copiado para a área de transferência\u{001F}copiar para a área de transferência\u{001F}Editor de código\u{001F}Executar\u{001F}primeira versão\u{001F}última versão\u{001F}maximizar visualização\u{001F}minimizar visualização\u{001F}próxima versão\u{001F}versão anterior\u{001F}redefinir entrada\u{001F}está sendo executado\u{001F}Enviar ao terminal\u{001F}terminal\u{001F}Ocultar comentários de vídeo e avatar\u{001F}Ajustar tom\u{001F}Tom\u{001F}Ajustar velocidade de reprodução\u{001F}Ritmo\u{001F}Comentários\u{001F}Não depender apenas de cores\u{001F}Abrir editor\u{001F}Informação\u{001F}Configurações\u{001F}Compartilhar\u{001F}compartilhar via ...\u{001F}Dicas de ferramentas\u{001F}Traduções\u{001F}Entrar em tela cheia\u{001F}Sair da tela cheia\u{001F}Início\u{001F}Autor: \u{001F}Autores: \u{001F}Data: \u{001F}Email: \u{001F}Baixar mídia para uso offline\u{001F}falharam\u{001F}Mídia offline\u{001F}Versão: \u{001F}Modo apresentação\u{001F}Ocultar navegação\u{001F}Apresentação\u{001F}Slides\u{001F}Livro-texto\u{001F}ainda não traduzido\u{001F}Código QR para site\u{001F}Ampliar código QR\u{001F}Erro durante a codificação para o código QR\u{001F}A resposta correta ainda não foi dada.\u{001F}Resposta revelada\u{001F}Parabéns, essa foi a resposta certa.\u{001F}Verificar\u{001F}Pressione Enter em uma área de soltar para selecioná-la e, em seguida, Enter em um cartão para colocá-lo nela\u{001F}Área de soltar\u{001F}vazia\u{001F}Lacuna\u{001F}mostrar dica\u{001F}Resposta\u{001F}Verifique a resposta. A resposta será marcada como correta ou incorreta.\u{001F}Mostrar a solução. O quiz será marcado como resolvido.\u{001F}seleção\u{001F}mostrar solução\u{001F}ordenar em ordem crescente\u{001F}ordenar em ordem decrescente\u{001F}não ordenado\u{001F}Som desligado\u{001F}Som ligado\u{001F}A pergunta deve ser respondida antes do envio.\u{001F}Todas as linhas devem ser respondidas antes do envio.\u{001F}Enviar\u{001F}Obrigado pelo seu feedback!\u{001F}Digite algum texto...\u{001F}Atualizar\u{001F}Traduzir com Google (experimental)\u{001F}de\u{001F}Pausar\u{001F}Posição de reprodução\u{001F}Preferir TTS do navegador\u{001F}Retomar\u{001F}Seu navegador não suporta Texto-para-Fala, tente outro.\u{001F}Usando o motor interno de Texto-para-Fala do navegador."


i18nRo : String
i18nRo =
    "Aa\u{001F}Închide dialogul\u{001F}șterge căutarea\u{001F}Stilul editorului\u{001F}dimensiunea fontului: \u{001E}\u{001F}Notă de subsol\u{001F}Note de subsol\u{001F}Română\u{001F}se deschide într-o filă nouă\u{001F}următorul\u{001F}niciun rezultat\u{001F}un rezultat\u{001F}redă\u{001F}anteriorul\u{001F}Redimensionează panourile\u{001F}rezultate\u{001F}Caută\u{001F}mică\u{001F}medie\u{001F}mare\u{001F}Sari peste navigare\u{001F}Diapozitiv\u{001F}Navigare între diapozitive\u{001F}Pas\u{001F}oprește\u{001F}Cuprins\u{001F}Mărește\u{001F}Albastru\u{001F}Mod luminos\u{001F}Culoare\u{001F}Mod întunecat\u{001F}Implicit\u{001F}Roșu\u{001F}Schemă de culori\u{001F}Turcoaz\u{001F}Galben\u{001F}Diagramă cu bare\u{001F}Diagramă cutie\u{001F}Diagramă\u{001F}Diagramă pâlnie\u{001F}Graf de relații\u{001F}Hartă termică\u{001F}Diagramă liniară\u{001F}Grafic liniar\u{001F}Hartă\u{001F}Diagramă cu coordonate paralele\u{001F}Diagramă circulară\u{001F}Diagramă radar\u{001F}Diagramă Sankey\u{001F}Diagramă de dispersie\u{001F}Tabel\u{001F}Nor de cuvinte\u{001F}Închide conversația\u{001F}Mesaj în conversație\u{001F}Ai mesaje necitite în conversație\u{001F}Deschide conversația\u{001F}Trimite mesajul\u{001F}Expeditor neverificat\u{001F}Bloc de cod\u{001F}copiat în clipboard\u{001F}copiază în clipboard\u{001F}Editor de cod\u{001F}Execută\u{001F}prima versiune\u{001F}ultima versiune\u{001F}maximizează vizualizarea\u{001F}minimizează vizualizarea\u{001F}versiunea următoare\u{001F}versiunea anterioară\u{001F}resetează valoarea introdusă\u{001F}se execută\u{001F}Trimite la terminal\u{001F}terminal\u{001F}Ascunde comentariile video și de avatar\u{001F}Ajustează înălțimea vocii\u{001F}Ton\u{001F}Ajustează viteza de redare\u{001F}Viteză\u{001F}Comentarii\u{001F}Nu te baza doar pe culori\u{001F}Deschide editorul\u{001F}Informații\u{001F}Setări\u{001F}Distribuie\u{001F}distribuie prin ...\u{001F}Indicații\u{001F}Traduceri\u{001F}Intră în modul ecran complet\u{001F}Ieși din modul ecran complet\u{001F}Acasă\u{001F}Autor: \u{001F}Autori: \u{001F}Data: \u{001F}E-mail: \u{001F}Descarcă media pentru utilizare offline\u{001F}eșuate\u{001F}Media offline\u{001F}Versiune: \u{001F}Mod de prezentare\u{001F}Ascunde navigarea\u{001F}Prezentare\u{001F}Diapozitive\u{001F}Manual\u{001F}nu există încă o traducere\u{001F}Cod QR pentru site\u{001F}Mărește codul QR\u{001F}Eroare la generarea codului QR\u{001F}Răspunsul corect nu a fost încă dat\u{001F}Răspuns dezvăluit\u{001F}Felicitări, acesta a fost răspunsul corect\u{001F}Verifică\u{001F}Apasă Enter pe o zonă de plasare pentru a o selecta, apoi Enter pe un card pentru a-l plasa acolo\u{001F}Zonă de plasare\u{001F}goală\u{001F}Spațiu liber\u{001F}arată indiciul\u{001F}Răspuns\u{001F}Verifică răspunsul. Răspunsul va fi marcat drept corect sau incorect.\u{001F}Arată soluția. Exercițiul va fi marcat ca rezolvat.\u{001F}selecție\u{001F}arată soluția\u{001F}sortează crescător\u{001F}sortează descrescător\u{001F}nesortat\u{001F}Dezactivează sunetul\u{001F}Activează sunetul\u{001F}Înainte de trimitere trebuie să se răspundă la întrebare.\u{001F}Înainte de trimitere trebuie să se răspundă pe fiecare rând.\u{001F}Trimite\u{001F}Îți mulțumim pentru feedback!\u{001F}Introdu un text...\u{001F}Actualizează\u{001F}Tradu cu Google (experimental)\u{001F}din\u{001F}Întrerupe\u{001F}Poziția redării\u{001F}Preferă sinteza vocală a browserului\u{001F}Reia\u{001F}Browserul tău nu acceptă sinteza vocală. Încearcă alt browser.\u{001F}Se utilizează motorul de sinteză vocală integrat în browser."


i18nRu : String
i18nRu =
    "Аа\u{001F}Закрыть диалог\u{001F}очистить поиск\u{001F}стиль редактора\u{001F}Размер шрифта: \u{001E}\u{001F}Сноска\u{001F}Сноски\u{001F}русский\u{001F}открывается в новой вкладке\u{001F}вперёд\u{001F}нет результатов\u{001F}один результат\u{001F}воспроизвести\u{001F}назад\u{001F}Изменить размер панелей\u{001F}результаты\u{001F}поиск\u{001F}мелкий\u{001F}средний\u{001F}большой\u{001F}Пропустить навигацию\u{001F}Слайд\u{001F}Навигация по слайдам\u{001F}Шаг\u{001F}остановить\u{001F}оглавление\u{001F}Увеличить\u{001F}синий\u{001F}светлый режим\u{001F}цвет\u{001F}темный режим\u{001F}по умолчанию\u{001F}красный\u{001F}Цветовая схема\u{001F}бирюзовый\u{001F}желтый\u{001F}Столбчатая диаграмма\u{001F}Диаграмма размаха\u{001F}Диаграмма\u{001F}Диаграмма-воронка\u{001F}Граф связей\u{001F}Тепловая карта\u{001F}Линейная диаграмма\u{001F}Линейный график\u{001F}Карта\u{001F}Диаграмма параллельных координат\u{001F}Круговая диаграмма\u{001F}Лепестковая диаграмма\u{001F}Диаграмма Санкея\u{001F}Точечная диаграмма\u{001F}Таблица\u{001F}Облако слов\u{001F}Закрыть чат\u{001F}Сообщение чата\u{001F}У вас есть непрочитанные сообщения в чате\u{001F}Открыть чат\u{001F}Отправить сообщение\u{001F}Неподтверждённый отправитель\u{001F}Блок кода\u{001F}скопировано в буфер обмена\u{001F}скопировать в буфер обмена\u{001F}Редактор кода\u{001F}выполнить\u{001F}первая версия\u{001F}последняя версия\u{001F}показать полностью\u{001F}свернуть\u{001F}следующая версия\u{001F}предыдущая версия\u{001F}сбросить ввод\u{001F}выполняется\u{001F}Отправить в терминал\u{001F}терминал\u{001F}Скрыть комментарии видео и аватара\u{001F}настройка высоты тона\u{001F}Тон\u{001F}настройка скорости воспроизведения\u{001F}Скорость\u{001F}Комментарии\u{001F}Не полагаться только на цвет\u{001F}открыть редактор\u{001F}информация\u{001F}настройки\u{001F}поделиться\u{001F}Отправить по ...\u{001F}подсказки\u{001F}на других языках\u{001F}перейти в полноэкранный режим\u{001F}выйти из полноэкранного режима\u{001F}нет войне\u{001F}автор: \u{001F}авторы: \u{001F}дата: \u{001F}эл. почта: \u{001F}Скачать медиафайлы для офлайн-использования\u{001F}не удалось\u{001F}Медиа офлайн\u{001F}версия: \u{001F}режим презентации\u{001F}Скрыть навигацию\u{001F}презентация\u{001F}слайды\u{001F}учебник\u{001F}перевода пока нет\u{001F}QR-код для сайта\u{001F}Увеличить QR-код\u{001F}Ошибка при кодировании в QR-код\u{001F}Правильный ответ еще не дан\u{001F}Раскрытый ответ\u{001F}Поздравляю, это был правильный ответ\u{001F}проверить\u{001F}Нажмите Enter на области размещения, чтобы выбрать её, затем Enter на карточке, чтобы поместить её туда\u{001F}Область размещения\u{001F}пустая\u{001F}Пропуск\u{001F}подсказка\u{001F}Ответ\u{001F}Проверьте ответ. Ответ будет отмечен как правильный или неправильный.\u{001F}Показать решение. Задание будет отмечено как решённое.\u{001F}выбор\u{001F}показать решение\u{001F}сортировать по возрастанию\u{001F}сортировать по убыванию\u{001F}не отсортировано\u{001F}звук выключен\u{001F}звук включён\u{001F}Перед отправкой необходимо ответить на вопрос.\u{001F}Перед отправкой необходимо ответить в каждой строке.\u{001F}отправить\u{001F}Спасибо за ваш отзыв!\u{001F}ввод текста\u{001F}Обновить\u{001F}Перевести с Google (экспериментально)\u{001F}из\u{001F}Пауза\u{001F}Позиция воспроизведения\u{001F}Предпочитать браузерный TTS\u{001F}Продолжить\u{001F}Ваш браузер не поддерживает преобразование текста в речь, попробуйте другой.\u{001F}Используется встроенный в браузер механизм преобразования текста в речь."


i18nSk : String
i18nSk =
    "Aa\u{001F}Zavrieť dialóg\u{001F}vymazať vyhľadávanie\u{001F}Štýl editora\u{001F}veľkosť písma: \u{001E}\u{001F}Poznámka pod čiarou\u{001F}Poznámky pod čiarou\u{001F}Slovenčina\u{001F}otvorí sa na novej karte\u{001F}ďalší\u{001F}žiadne výsledky\u{001F}jeden výsledok\u{001F}prehrať\u{001F}predchádzajúci\u{001F}Zmeniť veľkosť panelov\u{001F}výsledky\u{001F}Hľadať\u{001F}malá\u{001F}stredná\u{001F}veľká\u{001F}Preskočiť navigáciu\u{001F}Snímka\u{001F}Navigácia snímok\u{001F}Krok\u{001F}zastaviť\u{001F}Obsah\u{001F}Zväčšiť\u{001F}Modrá\u{001F}Svetlý režim\u{001F}Farba\u{001F}Tmavý režim\u{001F}Predvolené\u{001F}Červená\u{001F}Farebná schéma\u{001F}Tyrkysová\u{001F}Žltá\u{001F}Stĺpcový graf\u{001F}Krabicový graf\u{001F}Graf\u{001F}Lievikový graf\u{001F}Graf vzťahov\u{001F}Teplotná mapa\u{001F}Čiarový graf\u{001F}Čiarový graf\u{001F}Mapa\u{001F}Graf paralelných súradníc\u{001F}Koláčový graf\u{001F}Radarový graf\u{001F}Sankeyho diagram\u{001F}Bodový graf\u{001F}Tabuľka\u{001F}Oblak slov\u{001F}Zavrieť čet\u{001F}Správa v čete\u{001F}Máš neprečítané správy v čete\u{001F}Otvoriť čet\u{001F}Odoslať správu\u{001F}Neoverený odosielateľ\u{001F}Blok kódu\u{001F}skopírované do schránky\u{001F}kopírovať do schránky\u{001F}Editor kódu\u{001F}Spustiť\u{001F}prvá verzia\u{001F}posledná verzia\u{001F}maximalizovať zobrazenie\u{001F}minimalizovať zobrazenie\u{001F}ďalšia verzia\u{001F}predchádzajúca verzia\u{001F}obnoviť vstup\u{001F}beží\u{001F}Odoslať do terminálu\u{001F}terminál\u{001F}Skryť komentáre videa a avatara\u{001F}Upraviť výšku hlasu\u{001F}Výška\u{001F}Upraviť rýchlosť prehrávania\u{001F}Rýchlosť\u{001F}Komentáre\u{001F}Nespoliehať sa len na farby\u{001F}Otvoriť editor\u{001F}Informácie\u{001F}Nastavenia\u{001F}Zdieľať\u{001F}zdieľať cez ...\u{001F}Popisy nástrojov\u{001F}Preklady\u{001F}Prejsť na celú obrazovku\u{001F}Ukončiť režim celej obrazovky\u{001F}Domov\u{001F}Autor: \u{001F}Autori: \u{001F}Dátum: \u{001F}E-mail: \u{001F}Stiahnuť médiá na použitie offline\u{001F}zlyhalo\u{001F}Médiá offline\u{001F}Verzia: \u{001F}Režim prezentácie\u{001F}Skryť navigáciu\u{001F}Prezentácia\u{001F}Snímky\u{001F}Učebnica\u{001F}preklad zatiaľ nie je k dispozícii\u{001F}QR kód webovej stránky\u{001F}Zväčšiť QR kód\u{001F}Chyba pri vytváraní QR kódu\u{001F}Správna odpoveď ešte nebola zadaná\u{001F}Odhalená odpoveď\u{001F}Gratulujeme, to bola správna odpoveď\u{001F}Skontrolovať\u{001F}Stlačením Enter vyber cieľové pole, potom stlačením Enter na karte ju tam vlož\u{001F}Cieľové pole\u{001F}prázdne\u{001F}Medzera\u{001F}zobraziť nápovedu\u{001F}Odpoveď\u{001F}Skontrolovať odpoveď. Odpoveď bude označená ako správna alebo nesprávna.\u{001F}Zobraziť riešenie. Úloha bude označená ako vyriešená.\u{001F}výber\u{001F}zobraziť riešenie\u{001F}zoradiť vzostupne\u{001F}zoradiť zostupne\u{001F}nezoradené\u{001F}Zvuk vypnutý\u{001F}Zvuk zapnutý\u{001F}Pred odoslaním je potrebné odpovedať na otázku.\u{001F}Pred odoslaním je potrebné odpovedať v každom riadku.\u{001F}Odoslať\u{001F}Ďakujeme za spätnú väzbu!\u{001F}Zadaj text...\u{001F}Aktualizovať\u{001F}Preložiť pomocou Googlu (experimentálne)\u{001F}z\u{001F}Pozastaviť\u{001F}Pozícia prehrávania\u{001F}Uprednostniť syntézu reči prehliadača\u{001F}Pokračovať\u{001F}Tvoj prehliadač nepodporuje syntézu reči. Skús iný.\u{001F}Používa sa vstavaná syntéza reči prehliadača."


i18nSl : String
i18nSl =
    "Aa\u{001F}Zapri pogovorno okno\u{001F}počisti iskanje\u{001F}Slog urejevalnika\u{001F}velikost pisave: \u{001E}\u{001F}Opomba\u{001F}Opombe\u{001F}Slovenščina\u{001F}odpre se v novem zavihku\u{001F}naslednje\u{001F}ni rezultatov\u{001F}en rezultat\u{001F}predvajaj\u{001F}prejšnje\u{001F}Spremeni velikost podoken\u{001F}rezultati\u{001F}Išči\u{001F}majhna\u{001F}srednja\u{001F}velika\u{001F}Preskoči navigacijo\u{001F}Prosojnica\u{001F}Navigacija po prosojnicah\u{001F}Korak\u{001F}ustavi\u{001F}Kazalo vsebine\u{001F}Povečaj\u{001F}Modra\u{001F}Svetli način\u{001F}Barva\u{001F}Temni način\u{001F}Privzeto\u{001F}Rdeča\u{001F}Barvna shema\u{001F}Turkizna\u{001F}Rumena\u{001F}Stolpčni grafikon\u{001F}Škatla z brki\u{001F}Grafikon\u{001F}Lijakasti grafikon\u{001F}Graf povezav\u{001F}Toplotni zemljevid\u{001F}Črtni grafikon\u{001F}Črtni graf\u{001F}Zemljevid\u{001F}Grafikon vzporednih koordinat\u{001F}Tortni grafikon\u{001F}Radarski grafikon\u{001F}Sankeyjev diagram\u{001F}Raztreseni grafikon\u{001F}Tabela\u{001F}Oblak besed\u{001F}Zapri klepet\u{001F}Sporočilo v klepetu\u{001F}Imaš neprebrana sporočila v klepetu\u{001F}Odpri klepet\u{001F}Pošlji sporočilo\u{001F}Nepreverjen pošiljatelj\u{001F}Blok kode\u{001F}kopirano v odložišče\u{001F}kopiraj v odložišče\u{001F}Urejevalnik kode\u{001F}Zaženi\u{001F}prva različica\u{001F}zadnja različica\u{001F}povečaj pogled\u{001F}pomanjšaj pogled\u{001F}naslednja različica\u{001F}prejšnja različica\u{001F}ponastavi vnos\u{001F}se izvaja\u{001F}Pošlji v terminal\u{001F}terminal\u{001F}Skrij komentarje videa in avatarja\u{001F}Prilagodi višino glasu\u{001F}Višina\u{001F}Prilagodi hitrost predvajanja\u{001F}Hitrost\u{001F}Komentarji\u{001F}Ne zanašaj se le na barve\u{001F}Odpri urejevalnik\u{001F}Informacije\u{001F}Nastavitve\u{001F}Deli\u{001F}deli prek ...\u{001F}Namigi za orodja\u{001F}Prevodi\u{001F}Vklopi celozaslonski način\u{001F}Izklopi celozaslonski način\u{001F}Domov\u{001F}Avtor: \u{001F}Avtorji: \u{001F}Datum: \u{001F}E-pošta: \u{001F}Prenesi medije za uporabo brez povezave\u{001F}neuspešno\u{001F}Mediji brez povezave\u{001F}Različica: \u{001F}Način predstavitve\u{001F}Skrij navigacijo\u{001F}Predstavitev\u{001F}Prosojnice\u{001F}Učbenik\u{001F}prevod še ni na voljo\u{001F}Koda QR za spletno mesto\u{001F}Povečaj kodo QR\u{001F}Napaka pri ustvarjanju kode QR\u{001F}Pravilen odgovor še ni bil podan\u{001F}Razkrit odgovor\u{001F}Čestitamo, to je bil pravilen odgovor\u{001F}Preveri\u{001F}Pritisni Enter na ciljnem polju, da ga izbereš, nato Enter na kartici, da jo postaviš tja\u{001F}Ciljno polje\u{001F}prazno\u{001F}Vrzel\u{001F}pokaži namig\u{001F}Odgovor\u{001F}Preveri odgovor. Odgovor bo označen kot pravilen ali napačen.\u{001F}Pokaži rešitev. Naloga bo označena kot rešena.\u{001F}izbira\u{001F}pokaži rešitev\u{001F}razvrsti naraščajoče\u{001F}razvrsti padajoče\u{001F}nerazvrščeno\u{001F}Zvok izklopljen\u{001F}Zvok vklopljen\u{001F}Pred pošiljanjem je treba odgovoriti na vprašanje.\u{001F}Pred pošiljanjem je treba odgovoriti v vsaki vrstici.\u{001F}Pošlji\u{001F}Hvala za povratne informacije!\u{001F}Vnesi besedilo...\u{001F}Posodobi\u{001F}Prevedi z Googlom (poskusno)\u{001F}od\u{001F}Začasno ustavi\u{001F}Položaj predvajanja\u{001F}Prednostno uporabi sintezo govora v brskalniku\u{001F}Nadaljuj\u{001F}Tvoj brskalnik ne podpira sinteze govora. Poskusi drugega.\u{001F}Uporablja se vgrajena sinteza govora v brskalniku."


i18nSq : String
i18nSq =
    "Aa\u{001F}Mbyll dialogun\u{001F}pastro kërkimin\u{001F}Stili i redaktuesit\u{001F}madhësia e shkronjave: \u{001E}\u{001F}Shënim në fund të faqes\u{001F}Shënimet në fund të faqes\u{001F}Shqip\u{001F}hapet në një skedë të re\u{001F}tjetri\u{001F}asnjë rezultat\u{001F}një rezultat\u{001F}luaj\u{001F}i mëparshmi\u{001F}Ndrysho madhësinë e paneleve\u{001F}rezultate\u{001F}Kërko\u{001F}e vogël\u{001F}mesatare\u{001F}e madhe\u{001F}Kapërce navigimin\u{001F}Diapozitivi\u{001F}Navigimi i diapozitivave\u{001F}Hapi\u{001F}ndalo\u{001F}Pasqyra e lëndës\u{001F}Zmadho\u{001F}Blu\u{001F}Modaliteti i çelët\u{001F}Ngjyra\u{001F}Modaliteti i errët\u{001F}Parazgjedhja\u{001F}E kuqe\u{001F}Skema e ngjyrave\u{001F}Bruz\u{001F}E verdhë\u{001F}Diagram me shtylla\u{001F}Diagram kuti\u{001F}Diagram\u{001F}Diagram hinkë\u{001F}Graf marrëdhëniesh\u{001F}Hartë nxehtësie\u{001F}Diagram vijor\u{001F}Grafik vijor\u{001F}Hartë\u{001F}Diagram me koordinata paralele\u{001F}Diagram rrethor\u{001F}Diagram radar\u{001F}Diagram Sankey\u{001F}Diagram shpërndarjeje\u{001F}Tabela\u{001F}Re fjalësh\u{001F}Mbyll bisedën\u{001F}Mesazh bisede\u{001F}Ke mesazhe të palexuara në bisedë\u{001F}Hap bisedën\u{001F}Dërgo mesazh\u{001F}Dërgues i paverifikuar\u{001F}Blloku i kodit\u{001F}u kopjua në kujtesën e përkohshme\u{001F}kopjo në kujtesën e përkohshme\u{001F}Redaktuesi i kodit\u{001F}Ekzekuto\u{001F}versioni i parë\u{001F}versioni i fundit\u{001F}maksimizo pamjen\u{001F}minimizo pamjen\u{001F}versioni tjetër\u{001F}versioni i mëparshëm\u{001F}rivendos hyrjen\u{001F}po ekzekutohet\u{001F}Dërgo në terminal\u{001F}terminal\u{001F}Fshih komentet me video dhe avatar\u{001F}Rregullo lartësinë e zërit\u{001F}Toni\u{001F}Rregullo shpejtësinë e riprodhimit\u{001F}Ritmi\u{001F}Komentet\u{001F}Mos u mbështet vetëm te ngjyrat\u{001F}Hap redaktuesin\u{001F}Informacion\u{001F}Cilësimet\u{001F}Ndaj\u{001F}ndaj nëpërmjet ...\u{001F}Këshilla për mjetet\u{001F}Përkthime\u{001F}Hap ekranin e plotë\u{001F}Dil nga ekrani i plotë\u{001F}Kreu\u{001F}Autori: \u{001F}Autorët: \u{001F}Data: \u{001F}Email: \u{001F}Shkarko mediat për përdorim jashtë linje\u{001F}dështuan\u{001F}Mediat jashtë linje\u{001F}Versioni: \u{001F}Modaliteti i prezantimit\u{001F}Fshih navigimin\u{001F}Prezantim\u{001F}Diapozitiva\u{001F}Libër mësimor\u{001F}ende nuk ka përkthim\u{001F}Kodi QR për faqen e internetit\u{001F}Zmadho kodin QR\u{001F}Gabim gjatë krijimit të kodit QR\u{001F}Përgjigjja e saktë nuk është dhënë ende\u{001F}Përgjigjja e zbuluar\u{001F}Urime, kjo ishte përgjigjja e saktë\u{001F}Kontrollo\u{001F}Shtyp Enter mbi një zonë lëshimi për ta zgjedhur, pastaj Enter mbi një kartë për ta vendosur atje\u{001F}Zona e lëshimit\u{001F}bosh\u{001F}Boshllëku\u{001F}shfaq ndihmën\u{001F}Përgjigjja\u{001F}Kontrollo përgjigjen. Përgjigjja do të shënohet si e saktë ose e pasaktë.\u{001F}Shfaq zgjidhjen. Ushtrimi do të shënohet si i zgjidhur.\u{001F}përzgjedhje\u{001F}shfaq zgjidhjen\u{001F}rendit në rritje\u{001F}rendit në zbritje\u{001F}pa renditje\u{001F}Zëri i çaktivizuar\u{001F}Zëri i aktivizuar\u{001F}Para dërgimit duhet t'i jepet përgjigje pyetjes.\u{001F}Para dërgimit duhet t'i jepet përgjigje çdo rreshti.\u{001F}Dërgo\u{001F}Faleminderit për mendimin tënd!\u{001F}Shkruaj një tekst...\u{001F}Përditëso\u{001F}Përkthe me Google (eksperimentale)\u{001F}nga\u{001F}Pauzë\u{001F}Pozicioni i riprodhimit\u{001F}Prefero sintezën e të folurit të shfletuesit\u{001F}Vazhdo\u{001F}Shfletuesi yt nuk e mbështet sintezën e të folurit. Provo një tjetër.\u{001F}Po përdoret motori i integruar i sintezës së të folurit të shfletuesit."


i18nSv : String
i18nSv =
    "Aa\u{001F}Stäng dialogrutan\u{001F}rensa sökning\u{001F}Redigerarstil\u{001F}teckenstorlek: \u{001E}\u{001F}Fotnot\u{001F}Fotnoter\u{001F}Svenska\u{001F}öppnas i en ny flik\u{001F}nästa\u{001F}inga resultat\u{001F}ett resultat\u{001F}spela upp\u{001F}föregående\u{001F}Ändra storlek på panelerna\u{001F}resultat\u{001F}Sök\u{001F}liten\u{001F}medelstor\u{001F}stor\u{001F}Hoppa över navigeringen\u{001F}Bild\u{001F}Bildnavigering\u{001F}Steg\u{001F}stoppa\u{001F}Innehållsförteckning\u{001F}Förstora\u{001F}Blå\u{001F}Ljust läge\u{001F}Färg\u{001F}Mörkt läge\u{001F}Standard\u{001F}Röd\u{001F}Färgschema\u{001F}Turkos\u{001F}Gul\u{001F}Stapeldiagram\u{001F}Lådagram\u{001F}Diagram\u{001F}Trattdiagram\u{001F}Relationsgraf\u{001F}Värmekarta\u{001F}Linjediagram\u{001F}Linjegraf\u{001F}Karta\u{001F}Diagram med parallella koordinater\u{001F}Cirkeldiagram\u{001F}Radardiagram\u{001F}Sankeydiagram\u{001F}Spridningsdiagram\u{001F}Tabell\u{001F}Ordmoln\u{001F}Stäng chatten\u{001F}Chattmeddelande\u{001F}Du har olästa chattmeddelanden\u{001F}Öppna chatten\u{001F}Skicka meddelande\u{001F}Overifierad avsändare\u{001F}Kodblock\u{001F}kopierat till urklipp\u{001F}kopiera till urklipp\u{001F}Kodredigerare\u{001F}Kör\u{001F}första versionen\u{001F}senaste versionen\u{001F}maximera vyn\u{001F}minimera vyn\u{001F}nästa version\u{001F}föregående version\u{001F}återställ inmatning\u{001F}körs\u{001F}Skicka till terminalen\u{001F}terminal\u{001F}Dölj video- och avatarkommentarer\u{001F}Justera tonhöjd\u{001F}Tonhöjd\u{001F}Justera uppspelningshastighet\u{001F}Tempo\u{001F}Kommentarer\u{001F}Använd inte enbart färger\u{001F}Öppna redigeraren\u{001F}Information\u{001F}Inställningar\u{001F}Dela\u{001F}dela via ...\u{001F}Verktygstips\u{001F}Översättningar\u{001F}Aktivera helskärm\u{001F}Avsluta helskärm\u{001F}Hem\u{001F}Författare: \u{001F}Författare: \u{001F}Datum: \u{001F}E-post: \u{001F}Ladda ner media för offlineanvändning\u{001F}misslyckades\u{001F}Media offline\u{001F}Version: \u{001F}Presentationsläge\u{001F}Dölj navigering\u{001F}Presentation\u{001F}Bilder\u{001F}Lärobok\u{001F}ingen översättning ännu\u{001F}QR-kod för webbplatsen\u{001F}Förstora QR-koden\u{001F}Fel när QR-koden skapades\u{001F}Rätt svar har ännu inte angetts\u{001F}Avslöjat svar\u{001F}Grattis, det var rätt svar\u{001F}Kontrollera\u{001F}Tryck Enter på en släppyta för att välja den och sedan Enter på ett kort för att placera det där\u{001F}Släppyta\u{001F}tom\u{001F}Lucka\u{001F}visa ledtråd\u{001F}Svar\u{001F}Kontrollera svaret. Svaret markeras som rätt eller fel.\u{001F}Visa lösningen. Uppgiften markeras som löst.\u{001F}val\u{001F}visa lösning\u{001F}sortera stigande\u{001F}sortera fallande\u{001F}osorterat\u{001F}Ljud av\u{001F}Ljud på\u{001F}Frågan måste besvaras före inskickning.\u{001F}Alla rader måste besvaras före inskickning.\u{001F}Skicka\u{001F}Tack för din feedback!\u{001F}Skriv en text...\u{001F}Uppdatera\u{001F}Översätt med Google (experimentellt)\u{001F}av\u{001F}Pausa\u{001F}Uppspelningsposition\u{001F}Föredra webbläsarens talsyntes\u{001F}Fortsätt\u{001F}Din webbläsare stöder inte talsyntes. Prova en annan.\u{001F}Webbläsarens inbyggda talsyntes används."


i18nSw : String
i18nSw =
    "Aa\u{001F}Funga kidirisha\u{001F}futa utafutaji\u{001F}Mtindo wa Kihariri\u{001F}ukubwa wa fonti: \u{001E}\u{001F}Tanbihi\u{001F}Tanbihi\u{001F}Kiswahili\u{001F}hufunguka kwenye kichupo kipya\u{001F}ijayo\u{001F}hakuna matokeo\u{001F}tokeo moja\u{001F}cheza\u{001F}iliyopita\u{001F}Badilisha ukubwa wa vidirisha\u{001F}matokeo\u{001F}Tafuta\u{001F}ndogo\u{001F}ya kati\u{001F}kubwa\u{001F}Ruka urambazaji\u{001F}Slaidi\u{001F}Urambazaji wa slaidi\u{001F}Hatua\u{001F}simamisha\u{001F}Yaliyomo\u{001F}Kuza\u{001F}Bluu\u{001F}Hali ya Mwanga\u{001F}Rangi\u{001F}Hali ya Giza\u{001F}Chaguomsingi\u{001F}Nyekundu\u{001F}Mpango wa rangi\u{001F}Feruzi\u{001F}Njano\u{001F}Chati ya pau\u{001F}Boxplot\u{001F}Chati\u{001F}Chati ya faneli\u{001F}Grafu ya uhusiano\u{001F}Ramani ya joto\u{001F}Chati ya mstari\u{001F}Grafu ya mstari\u{001F}Ramani\u{001F}Chati ya viwianishi sambamba\u{001F}Chati ya pai\u{001F}Chati ya rada\u{001F}Mchoro wa Sankey\u{001F}Chati ya mtawanyiko\u{001F}Jedwali\u{001F}Wingu la maneno\u{001F}Funga gumzo\u{001F}Ujumbe wa gumzo\u{001F}Una ujumbe wa gumzo ambao haujasomwa\u{001F}Fungua gumzo\u{001F}Tuma ujumbe\u{001F}Mtumaji asiyethibitishwa\u{001F}Kipande cha msimbo\u{001F}imenakiliwa kwenye ubao wa kunakili\u{001F}nakili kwenye ubao wa kunakili\u{001F}Kihariri cha msimbo\u{001F}Tekeleza\u{001F}toleo la kwanza\u{001F}toleo la mwisho\u{001F}ongeza mtazamo\u{001F}punguza mtazamo\u{001F}toleo linalofuata\u{001F}toleo la awali\u{001F}weka upya ingizo\u{001F}inaendeshwa\u{001F}Tuma kwenye terminal\u{001F}terminal\u{001F}Ficha maoni ya video na avatar\u{001F}Badilisha kiwango cha sauti\u{001F}Kiwango\u{001F}Badilisha kasi ya kucheza\u{001F}Kasi\u{001F}Maoni\u{001F}Usitegemee rangi pekee\u{001F}Fungua Kihariri\u{001F}Taarifa\u{001F}Mipangilio\u{001F}Shiriki\u{001F}shiriki kupitia ...\u{001F}Vidokezo vya zana\u{001F}Tafsiri\u{001F}Ingia kwenye skrini kamili\u{001F}Toka kwenye skrini kamili\u{001F}Nyumbani\u{001F}Mwandishi: \u{001F}Waandishi: \u{001F}Tarehe: \u{001F}Barua pepe: \u{001F}Pakua media kwa matumizi nje ya mtandao\u{001F}imeshindwa\u{001F}Media nje ya mtandao\u{001F}Toleo: \u{001F}Hali ya uwasilishaji\u{001F}Ficha urambazaji\u{001F}Uwasilishaji\u{001F}Slaidi\u{001F}Kitabu cha kiada\u{001F}hakuna tafsiri bado\u{001F}Msimbo wa QR wa tovuti\u{001F}Kuza msimbo wa QR\u{001F}Hitilafu wakati wa kusimba msimbo wa QR\u{001F}Jibu sahihi bado halijatolewa\u{001F}Jibu lililotatuliwa\u{001F}Hongera, hilo lilikuwa jibu sahihi\u{001F}Angalia\u{001F}Bonyeza Enter kwenye eneo la kudondoshea ili kulichagua, kisha Enter kwenye kadi ili kuiweka hapo\u{001F}Eneo la kudondoshea\u{001F}tupu\u{001F}Pengo\u{001F}onyesha kidokezo\u{001F}Jibu\u{001F}Angalia jibu. Jibu litawekwa alama kuwa sahihi au si sahihi.\u{001F}Onyesha suluhisho. Maswali yatatiwa alama kuwa yametatuliwa.\u{001F}uteuzi\u{001F}onyesha suluhisho\u{001F}panga kwa kupanda\u{001F}panga kwa kushuka\u{001F}haijapangwa\u{001F}Sauti imezimwa\u{001F}Sauti imewashwa\u{001F}Swali linapaswa kujibiwa kabla ya kuwasilisha.\u{001F}Kila safu inapaswa kujibiwa kabla ya kuwasilisha.\u{001F}Wasilisha\u{001F}Asante kwa maoni yako!\u{001F}Weka maandishi...\u{001F}Sasisha\u{001F}Tafsiri na Google (majaribio)\u{001F}kati ya\u{001F}Sitisha\u{001F}Nafasi ya uchezaji\u{001F}Pendelea TTS ya kivinjari\u{001F}Endelea\u{001F}Kivinjari chako hakiauni Maandishi-hadi-Hotuba, jaribu kingine.\u{001F}Inatumia injini ya ndani ya kivinjari ya Maandishi-hadi-Hotuba."


i18nTr : String
i18nTr =
    "Aa\u{001F}İletişim kutusunu kapat\u{001F}aramayı temizle\u{001F}Düzenleyici stili\u{001F}yazı tipi boyutu: \u{001E}\u{001F}Dipnot\u{001F}Dipnotlar\u{001F}Türkçe\u{001F}yeni sekmede açılır\u{001F}sonraki\u{001F}sonuç yok\u{001F}bir sonuç\u{001F}oynat\u{001F}önceki\u{001F}Bölmeleri yeniden boyutlandır\u{001F}sonuçlar\u{001F}Ara\u{001F}küçük\u{001F}orta\u{001F}büyük\u{001F}Gezintiyi atla\u{001F}Slayt\u{001F}Slayt gezintisi\u{001F}Adım\u{001F}durdur\u{001F}İçindekiler\u{001F}Büyüt\u{001F}Mavi\u{001F}Açık mod\u{001F}Renk\u{001F}Koyu mod\u{001F}Varsayılan\u{001F}Kırmızı\u{001F}Renk şeması\u{001F}Turkuaz\u{001F}Sarı\u{001F}Çubuk grafiği\u{001F}Kutu grafiği\u{001F}Grafik\u{001F}Huni grafiği\u{001F}İlişki grafiği\u{001F}Isı haritası\u{001F}Çizgi grafiği\u{001F}Çizgi grafiği\u{001F}Harita\u{001F}Paralel koordinat grafiği\u{001F}Pasta grafiği\u{001F}Radar grafiği\u{001F}Sankey diyagramı\u{001F}Dağılım grafiği\u{001F}Tablo\u{001F}Kelime bulutu\u{001F}Sohbeti kapat\u{001F}Sohbet mesajı\u{001F}Okunmamış sohbet mesajlarınız var\u{001F}Sohbeti aç\u{001F}Mesaj gönder\u{001F}Doğrulanmamış gönderen\u{001F}Kod bloğu\u{001F}panoya kopyalandı\u{001F}panoya kopyala\u{001F}Kod düzenleyici\u{001F}Çalıştır\u{001F}ilk sürüm\u{001F}son sürüm\u{001F}görünümü büyüt\u{001F}görünümü küçült\u{001F}sonraki sürüm\u{001F}önceki sürüm\u{001F}girişi sıfırla\u{001F}çalışıyor\u{001F}Terminale gönder\u{001F}terminal\u{001F}Video ve avatar yorumlarını gizle\u{001F}Ses perdesini ayarla\u{001F}Perde\u{001F}Oynatma hızını ayarla\u{001F}Hız\u{001F}Yorumlar\u{001F}Yalnızca renge güvenme\u{001F}Düzenleyiciyi aç\u{001F}Bilgi\u{001F}Ayarlar\u{001F}Paylaş\u{001F}... aracılığıyla paylaş\u{001F}Araç ipuçları\u{001F}Çeviriler\u{001F}Tam ekrana geç\u{001F}Tam ekrandan çık\u{001F}Ana sayfa\u{001F}Yazar: \u{001F}Yazarlar: \u{001F}Tarih: \u{001F}E-posta: \u{001F}Medyayı çevrimdışı kullanım için indir\u{001F}başarısız\u{001F}Çevrimdışı medya\u{001F}Sürüm: \u{001F}Sunum modu\u{001F}Gezinmeyi gizle\u{001F}Sunum\u{001F}Slaytlar\u{001F}Ders kitabı\u{001F}henüz çeviri yok\u{001F}Web sitesi için QR kodu\u{001F}QR kodunu büyüt\u{001F}QR kodu oluşturulurken hata oluştu\u{001F}Henüz doğru yanıt verilmedi\u{001F}Açıklanan yanıt\u{001F}Tebrikler, doğru yanıt verdiniz\u{001F}Kontrol et\u{001F}Seçmek için bir bırakma alanında Enter'a, ardından oraya yerleştirmek için bir kartta Enter'a basın\u{001F}Bırakma alanı\u{001F}boş\u{001F}Boşluk\u{001F}ipucunu göster\u{001F}Yanıt\u{001F}Yanıtı kontrol et. Yanıt doğru veya yanlış olarak işaretlenecek.\u{001F}Çözümü göster. Soru çözülmüş olarak işaretlenecek.\u{001F}seçim\u{001F}çözümü göster\u{001F}artan sırada sırala\u{001F}azalan sırada sırala\u{001F}sıralanmamış\u{001F}Sesi kapat\u{001F}Sesi aç\u{001F}Göndermeden önce soru yanıtlanmalıdır.\u{001F}Göndermeden önce her satır yanıtlanmalıdır.\u{001F}Gönder\u{001F}Geri bildiriminiz için teşekkürler!\u{001F}Bir metin girin...\u{001F}Güncelle\u{001F}Google ile çevir (deneysel)\u{001F}/\u{001F}Duraklat\u{001F}Oynatma konumu\u{001F}Tarayıcının metin okuma özelliğini tercih et\u{001F}Devam et\u{001F}Tarayıcınız metin okumayı desteklemiyor. Başka bir tarayıcı deneyin.\u{001F}Tarayıcının yerleşik metin okuma motoru kullanılıyor."


i18nTw : String
i18nTw =
    "字\u{001F}關閉對話方塊\u{001F}清除搜尋\u{001F}編輯器樣式\u{001F}字體大小： \u{001E}\u{001F}註腳\u{001F}註腳\u{001F}繁體中文\u{001F}在新分頁中開啟\u{001F}繼續\u{001F}沒有結果\u{001F}一個結果\u{001F}播放\u{001F}返回\u{001F}調整窗格大小\u{001F}結果\u{001F}搜尋\u{001F}小\u{001F}中\u{001F}大\u{001F}跳過導覽\u{001F}投影片\u{001F}投影片導覽\u{001F}步驟\u{001F}停止\u{001F}目錄\u{001F}放大\u{001F}藍色\u{001F}亮模式\u{001F}顏色\u{001F}暗模式\u{001F}預設\u{001F}紅色\u{001F}配色方案\u{001F}綠松石色\u{001F}黃色\u{001F}長條圖\u{001F}箱形圖\u{001F}圖表\u{001F}漏斗圖\u{001F}關係圖\u{001F}熱度圖\u{001F}折線圖\u{001F}線圖\u{001F}地圖\u{001F}平行座標圖\u{001F}圓餅圖\u{001F}雷達圖\u{001F}桑基圖\u{001F}散佈圖\u{001F}表格\u{001F}文字雲\u{001F}關閉聊天室\u{001F}聊天訊息\u{001F}您有未讀的聊天訊息\u{001F}開啟聊天室\u{001F}發送訊息\u{001F}未驗證的傳送者\u{001F}程式碼區塊\u{001F}已複製到剪貼簿\u{001F}複製到剪貼簿\u{001F}程式碼編輯器\u{001F}開始執行\u{001F}最初版\u{001F}最終版\u{001F}最大化顯示\u{001F}最小化顯示\u{001F}下一版\u{001F}上一版\u{001F}重設輸入\u{001F}執行中\u{001F}傳送至終端機\u{001F}終端機\u{001F}隱藏影片與虛擬形象評論\u{001F}調整音高\u{001F}音高\u{001F}調整播放速度\u{001F}速度\u{001F}評論\u{001F}不只依賴顏色\u{001F}開啟編輯器\u{001F}關於\u{001F}設定\u{001F}分享\u{001F}透過...分享\u{001F}工具提示\u{001F}翻譯\u{001F}進入全螢幕模式\u{001F}退出全螢幕模式\u{001F}首頁\u{001F}作者: \u{001F}作者: \u{001F}日期: \u{001F}電郵: \u{001F}下載媒體以供離線使用\u{001F}失敗\u{001F}離線媒體\u{001F}版本: \u{001F}簡報模式\u{001F}隱藏導覽\u{001F}簡報\u{001F}投影片\u{001F}教科書\u{001F}尚未翻譯\u{001F}網站 QR 碼\u{001F}放大 QR 碼\u{001F}編碼為 QR 碼時出錯\u{001F}正確的答案還沒有被給出\u{001F}已顯示解答\u{001F}恭喜，這是正確答案\u{001F}檢查\u{001F}在放置區按 Enter 以選取，再在卡片上按 Enter 將其放到該處\u{001F}放置區\u{001F}空\u{001F}填空\u{001F}顯示提示\u{001F}答案\u{001F}檢查答案。答案將被標記為正確或錯誤。\u{001F}顯示解答。測驗將被標記為已解答。\u{001F}選擇\u{001F}顯示解答\u{001F}遞增排序\u{001F}遞減排序\u{001F}未排序\u{001F}聲音關閉\u{001F}聲音開啟\u{001F}提交前必須回答此問題。\u{001F}提交前必須回答每一列。\u{001F}提交\u{001F}感謝您的回饋！\u{001F}輸入文字...\u{001F}更新\u{001F}使用 Google 翻譯（實驗性）\u{001F}/\u{001F}暫停\u{001F}播放位置\u{001F}優先使用瀏覽器 TTS\u{001F}繼續\u{001F}您的瀏覽器不支援文字轉語音，請換一個瀏覽器。\u{001F}正在使用瀏覽器內建的文字轉語音引擎。"


i18nUk : String
i18nUk =
    "Аа\u{001F}Закрити діалог\u{001F}видалити пошук\u{001F}стиль редактора\u{001F}Розмір шрифту: \u{001E}\u{001F}Виноска\u{001F}Виноски\u{001F}Українська\u{001F}відкривається в новій вкладці\u{001F}далі\u{001F}немає результатів\u{001F}один результат\u{001F}відтворити\u{001F}назад\u{001F}Змінити розмір панелей\u{001F}результати\u{001F}пошук\u{001F}маленький\u{001F}середній\u{001F}великий\u{001F}Пропустити навігацію\u{001F}Слайд\u{001F}Навігація слайдами\u{001F}Крок\u{001F}зупинити\u{001F}зміст\u{001F}Збільшити\u{001F}синій\u{001F}світлий режим\u{001F}колір\u{001F}темний режим\u{001F}стандартний\u{001F}червоний\u{001F}Кольорова схема\u{001F}бірюзовий\u{001F}жовтий\u{001F}Стовпчикова діаграма\u{001F}Діаграма розмаху\u{001F}Діаграма\u{001F}Воронкова діаграма\u{001F}Граф зв'язків\u{001F}Теплова карта\u{001F}Лінійна діаграма\u{001F}Лінійний графік\u{001F}Карта\u{001F}Діаграма паралельних координат\u{001F}Кругова діаграма\u{001F}Радарна діаграма\u{001F}Діаграма Санкі\u{001F}Точкова діаграма\u{001F}Таблиця\u{001F}Хмара слів\u{001F}Закрити чат\u{001F}Повідомлення чату\u{001F}У вас є непрочитані повідомлення в чаті\u{001F}Відкрити чат\u{001F}Надіслати повідомлення\u{001F}Неперевірений відправник\u{001F}Блок коду\u{001F}скопійовано в буфер обміну\u{001F}копіювати в буфер обміну\u{001F}Редактор коду\u{001F}запустити\u{001F}перша версія\u{001F}остання версія\u{001F}збільшити вигляд\u{001F}зменшити вигляд\u{001F}наступна версія\u{001F}попередня версія\u{001F}скинути введення\u{001F}виконується\u{001F}Надіслати в термінал\u{001F}термінал\u{001F}Приховати коментарі до відео та аватара\u{001F}налаштування висоти тону\u{001F}Тон\u{001F}налаштування швидкості відтворення\u{001F}Темп\u{001F}Коментарі\u{001F}Не покладатися лише на колір\u{001F}відкрити редактор\u{001F}інформація\u{001F}налаштування\u{001F}поділитися\u{001F}поділитися через ...\u{001F}підказки\u{001F}переклади\u{001F}увімкнути повноекранний режим\u{001F}вийти з повноекранного режиму\u{001F}Головна\u{001F}автор: \u{001F}автори: \u{001F}дата: \u{001F}електронна пошта: \u{001F}Завантажити медіа для офлайн-використання\u{001F}не вдалося\u{001F}Медіа офлайн\u{001F}версія: \u{001F}режим презентації\u{001F}Сховати навігацію\u{001F}презентація\u{001F}слайди\u{001F}підручник\u{001F}переклад відсутній\u{001F}QR-код для вебсайту\u{001F}Збільшити QR-код\u{001F}Помилка під час кодування в QR-код\u{001F}Правильна відповідь ще не надана\u{001F}Вирішена відповідь\u{001F}Вітаю, це була правильна відповідь\u{001F}перевірити\u{001F}Натисніть Enter на зоні розміщення, щоб вибрати її, потім Enter на картці, щоб розмістити її там\u{001F}Зона розміщення\u{001F}порожня\u{001F}Пропуск\u{001F}показати підказку\u{001F}Відповідь\u{001F}Перевірте відповідь. Відповідь буде позначено як правильну чи неправильну.\u{001F}Покажіть розв’язок. Вікторину буде позначено як розв’язану.\u{001F}вибір\u{001F}показати розв'язок\u{001F}сортувати за зростанням\u{001F}сортувати за спаданням\u{001F}не відсортовано\u{001F}Звук вимкнено\u{001F}Звук увімкнено\u{001F}Перед надсиланням потрібно відповісти на запитання.\u{001F}Перед надсиланням потрібно відповісти в кожному рядку.\u{001F}Надіслати\u{001F}Дякуємо за ваш відгук!\u{001F}Введення тексту ...\u{001F}Оновити\u{001F}Перекласти за допомогою Google (експериментально)\u{001F}з\u{001F}Пауза\u{001F}Позиція відтворення\u{001F}Надавати перевагу TTS браузера\u{001F}Продовжити\u{001F}Ваш браузер не підтримує синтез мовлення з тексту, спробуйте інший.\u{001F}Використання внутрішньої системи синтезу мовлення у браузері."


i18nUr : String
i18nUr =
    "Aa\u{001F}ڈائیلاگ بند کریں\u{001F}تلاش صاف کریں\u{001F}ایڈیٹر اسٹائل\u{001F}فونٹ کا سائز: \u{001E}\u{001F}حاشیہ\u{001F}حواشی\u{001F}اردو\u{001F}نئے ٹیب میں کھلتا ہے\u{001F}اگلا\u{001F}کوئی نتیجہ نہیں\u{001F}ایک نتیجہ\u{001F}چلائیں\u{001F}پچھلا\u{001F}پینلز کا سائز تبدیل کریں\u{001F}نتائج\u{001F}تلاش\u{001F}چھوٹا\u{001F}درمیانہ\u{001F}بڑا\u{001F}نیویگیشن چھوڑیں\u{001F}سلائیڈ\u{001F}سلائیڈ نیویگیشن\u{001F}مرحلہ\u{001F}روکیں\u{001F}فہرست مشمولات\u{001F}بڑا کریں\u{001F}نیلا\u{001F}روشن موڈ\u{001F}رنگ\u{001F}تاریک موڈ\u{001F}پہلے سے طے شدہ\u{001F}سرخ\u{001F}رنگ سکیم\u{001F}فیروزی\u{001F}پیلا\u{001F}بار چارٹ\u{001F}باکس پلاٹ\u{001F}چارٹ\u{001F}فنل چارٹ\u{001F}رابطہ گراف\u{001F}ہیٹ میپ\u{001F}لائن چارٹ\u{001F}لائن گراف\u{001F}نقشہ\u{001F}متوازی کوآرڈینیٹ نقشہ\u{001F}پائی چارٹ\u{001F}ریڈار چارٹ\u{001F}سینکی ڈایاگرام\u{001F}اسکیٹر پلاٹ\u{001F}جدول\u{001F}ورڈ کلاؤڈ\u{001F}چیٹ بند کریں\u{001F}چیٹ پیغام\u{001F}آپ کے پاس ان پڑھے چیٹ پیغامات ہیں\u{001F}چیٹ کھولیں\u{001F}پیغام بھیجیں\u{001F}غیر تصدیق شدہ بھیجنے والا\u{001F}کوڈ بلاک\u{001F}کلپ بورڈ پر کاپی ہو گیا\u{001F}کلپ بورڈ پر کاپی کریں\u{001F}کوڈ ایڈیٹر\u{001F}چلائیں\u{001F}پہلا ورژن\u{001F}آخری ورژن\u{001F}منظر کو بڑا کریں\u{001F}منظر کو چھوٹا کریں\u{001F}اگلا ورژن\u{001F}پچھلا ورژن\u{001F}ان پٹ ری سیٹ کریں\u{001F}چل رہا ہے\u{001F}ٹرمینل کو بھیجیں\u{001F}ٹرمینل\u{001F}ویڈیو اور اوتار تبصرے چھپائیں\u{001F}آواز کی پچ ایڈجسٹ کریں\u{001F}پچ\u{001F}پلے بیک کی رفتار ایڈجسٹ کریں\u{001F}رفتار\u{001F}تبصرے\u{001F}صرف رنگوں پر انحصار نہ کریں\u{001F}ایڈیٹر کھولیں\u{001F}معلومات\u{001F}ترتیبات\u{001F}شیئر کریں\u{001F}... کے ذریعے شیئر کریں\u{001F}ٹول ٹپس\u{001F}ترجمے\u{001F}پوری سکرین\u{001F}پوری سکرین سے باہر\u{001F}ہوم\u{001F}مصنف: \u{001F}مصنفین: \u{001F}تاریخ: \u{001F}ای میل: \u{001F}آف لائن استعمال کے لیے میڈیا ڈاؤن لوڈ کریں\u{001F}ناکام\u{001F}میڈیا آف لائن\u{001F}ورژن: \u{001F}پریزنٹیشن موڈ\u{001F}نیویگیشن چھپائیں\u{001F}پریزنٹیشن\u{001F}سلائیڈز\u{001F}ٹیکسٹ بک\u{001F}ابھی تک کوئی ترجمہ نہیں\u{001F}ویب سائٹ کے لیے QR کوڈ\u{001F}QR کوڈ بڑا کریں\u{001F}QR کوڈ میں انکوڈ کرتے وقت خرابی\u{001F}صحیح جواب ابھی تک نہیں دیا گیا\u{001F}حل شدہ جواب\u{001F}مبارک ہو، یہ درست جواب تھا\u{001F}چیک کریں\u{001F}منتخب کرنے کے لیے کسی ڈراپ زون پر Enter دبائیں، پھر کسی کارڈ پر Enter دبا کر اسے وہاں رکھیں\u{001F}ڈراپ زون\u{001F}خالی\u{001F}خالی جگہ\u{001F}اشارہ دکھائیں\u{001F}جواب\u{001F}جواب چیک کریں۔ جواب کو درست یا غلط کے طور پر نشان زد کیا جائے گا۔\u{001F}حل دکھائیں۔ کوئز کو حل شدہ کے طور پر نشان زد کیا جائے گا۔\u{001F}انتخاب\u{001F}حل دکھائیں\u{001F}صعودی ترتیب\u{001F}نزولی ترتیب\u{001F}ترتیب نہیں دی گئی\u{001F}آواز بند\u{001F}آواز آن\u{001F}جمع کرانے سے پہلے سوال کا جواب دیا جانا ضروری ہے۔\u{001F}جمع کرانے سے پہلے ہر قطار کا جواب دیا جانا ضروری ہے۔\u{001F}جمع کریں\u{001F}آپ کی رائے کا شکریہ!\u{001F}کچھ متن درج کریں...\u{001F}اپ ڈیٹ کریں\u{001F}گوگل کے ساتھ ترجمہ کریں (تجرباتی)\u{001F}/\u{001F}توقف\u{001F}پلے بیک کی پوزیشن\u{001F}براؤزر TTS کو ترجیح دیں\u{001F}جاری رکھیں\u{001F}آپ کا براؤزر ٹیکسٹ ٹو اسپیچ کی حمایت نہیں کرتا، کوئی دوسرا آزمائیں۔\u{001F}براؤزر کے اندرونی ٹیکسٹ ٹو اسپیچ انجن کا استعمال ہو رہا ہے۔"


i18nZh : String
i18nZh =
    "字\u{001F}关闭对话框\u{001F}清除搜索\u{001F}编辑器样式\u{001F}字体大小： \u{001E}\u{001F}脚注\u{001F}脚注\u{001F}简体中文\u{001F}在新标签页中打开\u{001F}下一个\u{001F}没有结果\u{001F}一个结果\u{001F}播放\u{001F}上一个\u{001F}调整窗格大小\u{001F}结果\u{001F}搜索\u{001F}小\u{001F}中\u{001F}大\u{001F}跳过导航\u{001F}幻灯片\u{001F}幻灯片导航\u{001F}步骤\u{001F}停止\u{001F}目录\u{001F}放大\u{001F}蓝色\u{001F}浅色模式\u{001F}颜色\u{001F}深色模式\u{001F}默认\u{001F}红色\u{001F}配色方案\u{001F}绿松石色\u{001F}黄色\u{001F}柱状图\u{001F}箱线图\u{001F}图表\u{001F}漏斗图\u{001F}关系图\u{001F}热力图\u{001F}折线图\u{001F}线图\u{001F}地图\u{001F}平行坐标图\u{001F}饼图\u{001F}雷达图\u{001F}桑基图\u{001F}散点图\u{001F}表格\u{001F}词云\u{001F}关闭聊天\u{001F}聊天消息\u{001F}您有未读的聊天消息\u{001F}打开聊天\u{001F}发送消息\u{001F}未验证的发送者\u{001F}代码块\u{001F}已复制到剪贴板\u{001F}复制到剪贴板\u{001F}代码编辑器\u{001F}运行\u{001F}第一个版本\u{001F}最后一个版本\u{001F}最大化视图\u{001F}最小化视图\u{001F}下一版本\u{001F}上一版本\u{001F}重置输入\u{001F}正在运行\u{001F}发送到终端\u{001F}终端\u{001F}隐藏视频和虚拟形象讲解\u{001F}调整音高\u{001F}音高\u{001F}调整播放速度\u{001F}速度\u{001F}讲解\u{001F}不仅依靠颜色区分\u{001F}打开编辑器\u{001F}信息\u{001F}设置\u{001F}分享\u{001F}通过……分享\u{001F}工具提示\u{001F}翻译\u{001F}进入全屏模式\u{001F}退出全屏模式\u{001F}首页\u{001F}作者：\u{001F}作者：\u{001F}日期：\u{001F}电子邮件：\u{001F}下载媒体以供离线使用\u{001F}失败\u{001F}离线媒体\u{001F}版本：\u{001F}演示模式\u{001F}隐藏导航\u{001F}演示\u{001F}幻灯片\u{001F}教科书\u{001F}尚未翻译\u{001F}网站二维码\u{001F}放大二维码\u{001F}编码为二维码时出错\u{001F}尚未给出正确答案\u{001F}已显示解答\u{001F}恭喜，这是正确答案\u{001F}检查\u{001F}在放置区上按 Enter 键将其选中，然后在卡片上按 Enter 键将卡片放到那里\u{001F}放置区\u{001F}空\u{001F}填空\u{001F}显示提示\u{001F}答案\u{001F}检查答案。答案将被标记为正确或错误。\u{001F}显示解答。测验将被标记为已解答。\u{001F}选择\u{001F}显示解答\u{001F}升序排序\u{001F}降序排序\u{001F}未排序\u{001F}声音关闭\u{001F}声音开启\u{001F}提交前必须回答此问题。\u{001F}提交前必须回答每一行。\u{001F}提交\u{001F}感谢您的反馈！\u{001F}请输入文本……\u{001F}更新\u{001F}使用 Google 翻译（实验性）\u{001F}/\u{001F}暂停\u{001F}播放位置\u{001F}优先使用浏览器的文本转语音\u{001F}继续\u{001F}您的浏览器不支持文本转语音，请换一个浏览器。\u{001F}使用浏览器的内部文本转语音引擎。"


baseAbc : Lang -> String
baseAbc lang =
    i18nGet 0 "Aa" lang


baseCloseDialog : Lang -> String
baseCloseDialog lang =
    i18nGet 1 "Close dialog" lang


baseDelete : Lang -> String
baseDelete lang =
    i18nGet 2 "clear search" lang


baseEditor : Lang -> String
baseEditor lang =
    i18nGet 3 "Editor-Style" lang


baseFont : Lang -> String -> String
baseFont lang str0 =
    i18nFill [ str0 ] (i18nGet 4 "font size: \u{001E}" lang)


baseFootnote : Lang -> String
baseFootnote lang =
    i18nGet 5 "Footnote" lang


baseFootnotes : Lang -> String
baseFootnotes lang =
    i18nGet 6 "Footnotes" lang


baseLang : Lang -> String
baseLang lang =
    i18nGet 7 "English" lang


baseNewTab : Lang -> String
baseNewTab lang =
    i18nGet 8 "opens in a new tab" lang


baseNext : Lang -> String
baseNext lang =
    i18nGet 9 "next" lang


baseNoResult : Lang -> String
baseNoResult lang =
    i18nGet 10 "no results" lang


baseOneResult : Lang -> String
baseOneResult lang =
    i18nGet 11 "one result" lang


basePlay : Lang -> String
basePlay lang =
    i18nGet 12 "play" lang


basePrev : Lang -> String
basePrev lang =
    i18nGet 13 "previous" lang


baseResize : Lang -> String
baseResize lang =
    i18nGet 14 "Resize panes" lang


baseResults : Lang -> String
baseResults lang =
    i18nGet 15 "results" lang


baseSearch : Lang -> String
baseSearch lang =
    i18nGet 16 "Search" lang


baseSize1 : Lang -> String
baseSize1 lang =
    i18nGet 17 "small" lang


baseSize2 : Lang -> String
baseSize2 lang =
    i18nGet 18 "medium" lang


baseSize3 : Lang -> String
baseSize3 lang =
    i18nGet 19 "large" lang


baseSkipNav : Lang -> String
baseSkipNav lang =
    i18nGet 20 "Skip navigation" lang


baseSlide : Lang -> String
baseSlide lang =
    i18nGet 21 "Slide" lang


baseSlideNavigation : Lang -> String
baseSlideNavigation lang =
    i18nGet 22 "Slide navigation" lang


baseStep : Lang -> String
baseStep lang =
    i18nGet 23 "Step" lang


baseStop : Lang -> String
baseStop lang =
    i18nGet 24 "stop" lang


baseToc : Lang -> String
baseToc lang =
    i18nGet 25 "Table of Contents" lang


baseZoom : Lang -> String
baseZoom lang =
    i18nGet 26 "Enlarge" lang


cBlue : Lang -> String
cBlue lang =
    i18nGet 27 "Blue" lang


cBright : Lang -> String
cBright lang =
    i18nGet 28 "Light-Mode" lang


cColor : Lang -> String
cColor lang =
    i18nGet 29 "Color" lang


cDark : Lang -> String
cDark lang =
    i18nGet 30 "Dark-Mode" lang


cDefault : Lang -> String
cDefault lang =
    i18nGet 31 "Default" lang


cRed : Lang -> String
cRed lang =
    i18nGet 32 "Red" lang


cSchema : Lang -> String
cSchema lang =
    i18nGet 33 "Color scheme" lang


cTurquoise : Lang -> String
cTurquoise lang =
    i18nGet 34 "Turquoise" lang


cYellow : Lang -> String
cYellow lang =
    i18nGet 35 "Yellow" lang


chartBar : Lang -> String
chartBar lang =
    i18nGet 36 "Bar chart" lang


chartBoxplot : Lang -> String
chartBoxplot lang =
    i18nGet 37 "Boxplot" lang


chartDefault : Lang -> String
chartDefault lang =
    i18nGet 38 "Chart" lang


chartFunnel : Lang -> String
chartFunnel lang =
    i18nGet 39 "Funnel chart" lang


chartGraph : Lang -> String
chartGraph lang =
    i18nGet 40 "Relationship graph" lang


chartHeatmap : Lang -> String
chartHeatmap lang =
    i18nGet 41 "Heat map" lang


chartLine : Lang -> String
chartLine lang =
    i18nGet 42 "Line chart" lang


chartLines : Lang -> String
chartLines lang =
    i18nGet 43 "Line graph" lang


chartMap : Lang -> String
chartMap lang =
    i18nGet 44 "Map" lang


chartParallel : Lang -> String
chartParallel lang =
    i18nGet 45 "Parallel coordinate map" lang


chartPie : Lang -> String
chartPie lang =
    i18nGet 46 "Pie chart" lang


chartRadar : Lang -> String
chartRadar lang =
    i18nGet 47 "Radar chart" lang


chartSankey : Lang -> String
chartSankey lang =
    i18nGet 48 "Sankey diagram" lang


chartScatter : Lang -> String
chartScatter lang =
    i18nGet 49 "Scatter plot" lang


chartTable : Lang -> String
chartTable lang =
    i18nGet 50 "Table" lang


chartWordcloud : Lang -> String
chartWordcloud lang =
    i18nGet 51 "Word cloud" lang


chatClose : Lang -> String
chatClose lang =
    i18nGet 52 "Close chat" lang


chatMessage : Lang -> String
chatMessage lang =
    i18nGet 53 "Chat message" lang


chatNew : Lang -> String
chatNew lang =
    i18nGet 54 "You have unread chat messages" lang


chatOpen : Lang -> String
chatOpen lang =
    i18nGet 55 "Open chat" lang


chatSend : Lang -> String
chatSend lang =
    i18nGet 56 "Send message" lang


chatUnverified : Lang -> String
chatUnverified lang =
    i18nGet 57 "Unverified sender" lang


codeBlock : Lang -> String
codeBlock lang =
    i18nGet 58 "Code block" lang


codeCopied : Lang -> String
codeCopied lang =
    i18nGet 59 "copied to clipboard" lang


codeCopy : Lang -> String
codeCopy lang =
    i18nGet 60 "copy to clipboard" lang


codeEditor : Lang -> String
codeEditor lang =
    i18nGet 61 "Code editor" lang


codeExecute : Lang -> String
codeExecute lang =
    i18nGet 62 "Execute" lang


codeFirst : Lang -> String
codeFirst lang =
    i18nGet 63 "first version" lang


codeLast : Lang -> String
codeLast lang =
    i18nGet 64 "last version" lang


codeMaximize : Lang -> String
codeMaximize lang =
    i18nGet 65 "maximize view" lang


codeMinimize : Lang -> String
codeMinimize lang =
    i18nGet 66 "minimize view" lang


codeNext : Lang -> String
codeNext lang =
    i18nGet 67 "next version" lang


codePrev : Lang -> String
codePrev lang =
    i18nGet 68 "previous version" lang


codeReset : Lang -> String
codeReset lang =
    i18nGet 69 "reset input" lang


codeRunning : Lang -> String
codeRunning lang =
    i18nGet 70 "is running" lang


codeSendTerminal : Lang -> String
codeSendTerminal lang =
    i18nGet 71 "Send to terminal" lang


codeTerminal : Lang -> String
codeTerminal lang =
    i18nGet 72 "terminal" lang


commentHide : Lang -> String
commentHide lang =
    i18nGet 73 "Hide video & avatar comments" lang


commentPitch : Lang -> String
commentPitch lang =
    i18nGet 74 "Adjust pitch" lang


commentPitchLabel : Lang -> String
commentPitchLabel lang =
    i18nGet 75 "Pitch" lang


commentRate : Lang -> String
commentRate lang =
    i18nGet 76 "Adjust playback speed" lang


commentRateLabel : Lang -> String
commentRateLabel lang =
    i18nGet 77 "Speed" lang


commentSidebar : Lang -> String
commentSidebar lang =
    i18nGet 78 "Comments" lang


confDecals : Lang -> String
confDecals lang =
    i18nGet 79 "Do not rely on color alone" lang


confEdit : Lang -> String
confEdit lang =
    i18nGet 80 "Open editor" lang


confInformation : Lang -> String
confInformation lang =
    i18nGet 81 "Information" lang


confSettings : Lang -> String
confSettings lang =
    i18nGet 82 "Settings" lang


confShare : Lang -> String
confShare lang =
    i18nGet 83 "Share" lang


confShareVia : Lang -> String
confShareVia lang =
    i18nGet 84 "share via ..." lang


confTooltip : Lang -> String
confTooltip lang =
    i18nGet 85 "Tooltips" lang


confTranslations : Lang -> String
confTranslations lang =
    i18nGet 86 "Translations" lang


fullscreenEnter : Lang -> String
fullscreenEnter lang =
    i18nGet 87 "Enter Fullscreen" lang


fullscreenExit : Lang -> String
fullscreenExit lang =
    i18nGet 88 "Exit Fullscreen" lang


home : Lang -> String
home lang =
    i18nGet 89 "Home" lang


infoAuthor : Lang -> String
infoAuthor lang =
    i18nGet 90 "Author: " lang


infoAuthors : Lang -> String
infoAuthors lang =
    i18nGet 91 "Authors: " lang


infoDate : Lang -> String
infoDate lang =
    i18nGet 92 "Date: " lang


infoEmail : Lang -> String
infoEmail lang =
    i18nGet 93 "Email: " lang


infoOffline : Lang -> String
infoOffline lang =
    i18nGet 94 "Download media for offline use" lang


infoOfflineFailed : Lang -> String
infoOfflineFailed lang =
    i18nGet 95 "failed" lang


infoOfflineStatus : Lang -> String
infoOfflineStatus lang =
    i18nGet 96 "Media offline" lang


infoVersion : Lang -> String
infoVersion lang =
    i18nGet 97 "Version: " lang


modeMode : Lang -> String
modeMode lang =
    i18nGet 98 "Presentation mode" lang


modeNavigation : Lang -> String
modeNavigation lang =
    i18nGet 99 "Hide navigation" lang


modePresentation : Lang -> String
modePresentation lang =
    i18nGet 100 "Presentation" lang


modeSlides : Lang -> String
modeSlides lang =
    i18nGet 101 "Slides" lang


modeTextbook : Lang -> String
modeTextbook lang =
    i18nGet 102 "Textbook" lang


no_translation : Lang -> String
no_translation lang =
    i18nGet 103 "no translation yet" lang


qrCode : Lang -> String
qrCode lang =
    i18nGet 104 "QR code for website" lang


qrEnlarge : Lang -> String
qrEnlarge lang =
    i18nGet 105 "Enlarge QR code" lang


qrErr : Lang -> String
qrErr lang =
    i18nGet 106 "Error while encoding to QR code" lang


quizAnswerError : Lang -> String
quizAnswerError lang =
    i18nGet 107 "The correct answer has not yet been given" lang


quizAnswerResolved : Lang -> String
quizAnswerResolved lang =
    i18nGet 108 "Resolved answer" lang


quizAnswerSuccess : Lang -> String
quizAnswerSuccess lang =
    i18nGet 109 "Congratulations, that was the right answer" lang


quizCheck : Lang -> String
quizCheck lang =
    i18nGet 110 "Check" lang


quizDragHint : Lang -> String
quizDragHint lang =
    i18nGet 111 "Press Enter on a drop zone to select it, then Enter on a card to place it there" lang


quizDropZone : Lang -> String
quizDropZone lang =
    i18nGet 112 "Drop zone" lang


quizEmpty : Lang -> String
quizEmpty lang =
    i18nGet 113 "empty" lang


quizGap : Lang -> String
quizGap lang =
    i18nGet 114 "Gap" lang


quizHint : Lang -> String
quizHint lang =
    i18nGet 115 "show hint" lang


quizInput : Lang -> String
quizInput lang =
    i18nGet 116 "Answer" lang


quizLabelCheck : Lang -> String
quizLabelCheck lang =
    i18nGet 117 "Check the answer. The response will be marked as correct or incorrect." lang


quizLabelSolution : Lang -> String
quizLabelSolution lang =
    i18nGet 118 "Show the solution. The quiz will be marked as resolved." lang


quizSelection : Lang -> String
quizSelection lang =
    i18nGet 119 "selection" lang


quizSolution : Lang -> String
quizSolution lang =
    i18nGet 120 "show solution" lang


sortAsc : Lang -> String
sortAsc lang =
    i18nGet 121 "sort ascending" lang


sortDesc : Lang -> String
sortDesc lang =
    i18nGet 122 "sort descending" lang


sortNot : Lang -> String
sortNot lang =
    i18nGet 123 "not sorted" lang


soundOff : Lang -> String
soundOff lang =
    i18nGet 124 "Sound off" lang


soundOn : Lang -> String
soundOn lang =
    i18nGet 125 "Sound on" lang


surveyError : Lang -> String
surveyError lang =
    i18nGet 126 "This question must be answered before submitting." lang


surveyErrorMatrix : Lang -> String
surveyErrorMatrix lang =
    i18nGet 127 "Every row must be answered before submitting." lang


surveySubmit : Lang -> String
surveySubmit lang =
    i18nGet 128 "Submit" lang


surveySubmitted : Lang -> String
surveySubmitted lang =
    i18nGet 129 "Thank you for your feedback!" lang


surveyText : Lang -> String
surveyText lang =
    i18nGet 130 "Enter some text..." lang


surveyUpdate : Lang -> String
surveyUpdate lang =
    i18nGet 131 "Update" lang


translateWithGoogle : Lang -> String
translateWithGoogle lang =
    i18nGet 132 "Translate with Google (experimental)" lang


ttsOf : Lang -> String
ttsOf lang =
    i18nGet 133 "of" lang


ttsPause : Lang -> String
ttsPause lang =
    i18nGet 134 "Pause" lang


ttsPosition : Lang -> String
ttsPosition lang =
    i18nGet 135 "Playback position" lang


ttsPreferBrowser : Lang -> String
ttsPreferBrowser lang =
    i18nGet 136 "Prefer browser TTS" lang


ttsResume : Lang -> String
ttsResume lang =
    i18nGet 137 "Resume" lang


ttsUnsupported : Lang -> String
ttsUnsupported lang =
    i18nGet 138 "Your browser does not support Text-to-Speech, try another one." lang


ttsUsingBrowser : Lang -> String
ttsUsingBrowser lang =
    i18nGet 139 "Using the browser's internal Text-to-Speech engine." lang
