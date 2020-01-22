﻿///////////////////////////////////////////////////////////////////////////////////////////////
// МОДУЛЬ СОДЕРЖИТ ПРОЦЕДУРЫ И ФУНКЦИИ РАБОТЫ С ВНУТРЕННИМИ, ВХОДЯЩИМИ И ИСХОДЯЩИМИ ДОКУМЕНТАМИ
// 

#Область ПрограммныйИнтерфейс

// Проверяет, находится ли документ на исполнении (на исполнении либо исполнен,
//  на рассмотрении либо рассмотрен, на ознакомлении)
//
// Параметры:
//  Документ - СправочникСсылка	 - ссылка на внутренний либо входящий документ
// 
// Возвращаемое значение:
//  Булево - Истина, если документ на исполнении, Ложь - если нет
//
Функция ПроверитьСостояниеДокументаНаИсполнении(Знач Документ) Экспорт
		
	Если Не ПолучитьФункциональнуюОпцию("ИспользоватьСостоянияДокументов") Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(Документ) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	МассивСостояний = Делопроизводство.ПолучитьВсеСостоянияДокумента(Документ).ВыгрузитьКолонку("Состояние");
		
	СоответствиеСостоянийНаИсполнении = ПолучитьСоответствиеСостоянийНаИсполнении();
	
	Для Каждого Состояние Из МассивСостояний Цикл
		Если СоответствиеСостоянийНаИсполнении.Получить(Состояние) Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

// Возвращает значения реквизитов документа, прочитанные из информационной базы.
// 
//  Если доступа к одному из реквизитов нет, возникнет исключение прав доступа.
//  Если необходимо зачитать реквизит независимо от прав текущего пользователя,
//  то следует использовать предварительный переход в привилегированный режим.
//
// Функция не предназначена для получения значений реквизитов пустых ссылок.
// 
// Параметры:
//  Документ - СправочникСсылка	 - ссылка на документ
//
//  Реквизиты - Строка - имена реквизитов, перечисленные через запятую, в формате
//              требований к свойствам структуры.
//              Например, "Код, Наименование, Родитель".
//            - Массив, ФиксированныйМассив - имена реквизитов в формате требований
//              к свойствам структуры.
//
// Возвращаемое значение:
//  Структура - содержит имена (ключи) и значения затребованных реквизитов.
//              Если строка затребованных реквизитов пуста, то возвращается пустая структура.
//              Если в качестве объекта передана пустая ссылка, то все реквизиты вернутся со значением Неопределено.
//
Функция ЗначенияРеквизитовДокумента(Знач Документ, Знач Реквизиты) Экспорт
	
	Контекст = "ИТГ_Делопроизводство.ЗначенияРеквизитовДокумента";
	
	ОбщегоНазначенияКлиентСервер.Проверить(
		ДелопроизводствоКлиентСервер.ЭтоСсылкаНаДокумент(Документ),
		НСтр("ru = 'Недопустимое значение параметра Документ, 
			|Ожидалась ссылка на документ'",
			ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
		Контекст);
		
	ОбщегоНазначенияКлиентСервер.ПроверитьПараметр(
		Контекст,
		"Реквизиты",
		Реквизиты,
		Новый ОписаниеТипов("Строка, Массив, ФиксированныйМассив"));
		
	Если ТипЗнч(Реквизиты) = Тип("Строка")Тогда
		СтруктураРеквизитов = Новый Структура(Реквизиты);
	ИначеЕсли ТипЗнч(Реквизиты) = Тип("Структура") Или ТипЗнч(Реквизиты) = Тип("ФиксированнаяСтруктура") Тогда
		СтруктураРеквизитов = ОбщегоНазначенияКлиентСервер.СкопироватьСтруктуру(Реквизиты);
	ИначеЕсли ТипЗнч(Реквизиты) = Тип("Массив") Или ТипЗнч(Реквизиты) = Тип("ФиксированныйМассив") Тогда
		СтруктураРеквизитов = Новый Структура;
		Для Каждого Реквизит Из Реквизиты Цикл
			СтруктураРеквизитов.Вставить(СтрЗаменить(Реквизит, ".", ""), Реквизит);
		КонецЦикла;
	КонецЕсли;
	
	Если (
			СтруктураРеквизитов.Свойство("Адресат")
			Или СтруктураРеквизитов.Свойство("Организация")
		) И Не СтруктураРеквизитов.Свойство("ВидДокумента") Тогда
		
		СтруктураРеквизитов.Вставить("ВидДокумента");
		
	КонецЕсли;
	
	РеквизитыДокумента = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Документ, СтруктураРеквизитов);
	
	Если СтруктураРеквизитов.Свойство("Адресат") Тогда
		Если ДелопроизводствоКлиентСервер.ЭтоВнутреннийДокумент(Документ) Тогда 
			ДляДокументовЭтогоВидаИспользуетсяУчетПоАдресатам = ПолучитьФункциональнуюОпцию("ВестиУчетПоАдресатам",
				Новый Структура("ВидВнутреннегоДокумента", РеквизитыДокумента.ВидДокумента));
			ОбщегоНазначенияКлиентСервер.Проверить(
				ДляДокументовЭтогоВидаИспользуетсяУчетПоАдресатам,
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр(
						"ru = 'Невозможно получение адресата документа ""%1"". Для документов вида ""%2"" не используется учёт по адресатам'",
						ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
					Строка(Документ), Строка(РеквизитыДокумента.ВидДокумента)),
				Контекст);
		КонецЕсли;
		ОбщегоНазначенияКлиентСервер.Проверить(
			ЗначениеЗаполнено(РеквизитыДокумента.Адресат),
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр(
					"ru = 'Невозможно получение адресата документа ""%1"". В документе не указан адресат'",
					ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				Строка(Документ)),
			Контекст);
	КонецЕсли;
		
	Если СтруктураРеквизитов.Свойство("Организация") Тогда
		ИспользоватьУчетПоОрганизациям = ПолучитьФункциональнуюОпцию("ИспользоватьУчетПоОрганизациям");
		ОбщегоНазначенияКлиентСервер.Проверить(
			ИспользоватьУчетПоОрганизациям,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр(
					"ru = 'Невозможно получение организации документа ""%1"". В системе не используется учёт по организациям'",
					ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				Строка(Документ)),
			Контекст);
		Если ДелопроизводствоКлиентСервер.ЭтоВнутреннийДокумент(Документ) Тогда 
			ДляДокументовЭтогоВидаИспользуетсяУчетПоОрганизациям = ПолучитьФункциональнуюОпцию("ВестиУчетПоОрганизациям",
				Новый Структура("ВидВнутреннегоДокумента", РеквизитыДокумента.ВидДокумента));
			ОбщегоНазначенияКлиентСервер.Проверить(
				ДляДокументовЭтогоВидаИспользуетсяУчетПоОрганизациям,
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Невозможно получение организации документа ""%1"".
						|Включен учёт по организациям.
						|Однако, для внутренних документов вида ""%2"" учёт по организациям не предусмотрен'",
						ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
					Строка(Документ), Строка(РеквизитыДокумента.ВидДокумента)),
				Контекст);
		КонецЕсли;
		ОбщегоНазначенияКлиентСервер.Проверить(
			ЗначениеЗаполнено(РеквизитыДокумента.Организация),
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр(
					"ru = 'Невозможно получение организации документа ""%1"". В документе не указана организация'",
					ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				Строка(Документ)),
			Контекст);
	КонецЕсли;
		
	Если СтруктураРеквизитов.Свойство("Подразделение") Тогда
		ОбщегоНазначенияКлиентСервер.Проверить(
			ЗначениеЗаполнено(РеквизитыДокумента.Подразделение),
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр(
					"ru = 'Невозможно получение подразделения документа ""%1"". В документе не указано подразделение'",
					ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				Строка(Документ)),
			Контекст);
	КонецЕсли;
		
	Возврат РеквизитыДокумента;
	
КонецФункции

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Возвращает соответствие состояний документов на стадии исполнения (на исполнении либо исполнен,
//  на рассмотрении либо рассмотрен, на ознакомлении)
// 
// Возвращаемое значение:
//  Соответствие
//
Функция ПолучитьСоответствиеСостоянийНаИсполнении() Экспорт  
	
	Соответствие = Новый Соответствие;
	
	Соответствие.Вставить(Перечисления.СостоянияДокументов.НаСогласовании, 	  Ложь);
	Соответствие.Вставить(Перечисления.СостоянияДокументов.НеСогласован, 	  Ложь);
	Соответствие.Вставить(Перечисления.СостоянияДокументов.Согласован, 		  Ложь);
	
	Соответствие.Вставить(Перечисления.СостоянияДокументов.НаУтверждении, 	  Ложь);
	Соответствие.Вставить(Перечисления.СостоянияДокументов.НеУтвержден, 	  Ложь);
	Соответствие.Вставить(Перечисления.СостоянияДокументов.Утвержден, 		  Ложь);
	
	Соответствие.Вставить(Перечисления.СостоянияДокументов.НаПодписании, 	  Ложь);
	Соответствие.Вставить(Перечисления.СостоянияДокументов.Отклонен,		  Ложь);
	Соответствие.Вставить(Перечисления.СостоянияДокументов.Подписан, 		  Ложь);
	
	Соответствие.Вставить(Перечисления.СостоянияДокументов.Проект, 			  Ложь);
	Соответствие.Вставить(Перечисления.СостоянияДокументов.НаРегистрации, 	  Ложь);
	Соответствие.Вставить(Перечисления.СостоянияДокументов.Зарегистрирован,   Ложь);
	Соответствие.Вставить(Перечисления.СостоянияДокументов.НеЗарегистрирован, Ложь);
	
	Соответствие.Вставить(Перечисления.СостоянияДокументов.НаРассмотрении, 	  Истина);
	Соответствие.Вставить(Перечисления.СостоянияДокументов.Рассмотрен, 	   	  Истина);
	
	Соответствие.Вставить(Перечисления.СостоянияДокументов.НаИсполнении, 	  Истина);
	Соответствие.Вставить(Перечисления.СостоянияДокументов.Исполнен, 		  Истина);
	
	Возврат Соответствие;
	
КонецФункции	

#КонецОбласти
