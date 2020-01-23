﻿////////////////////////////////////////////////////////////////////////////////
// Программный интерфейс бизнес-событий

#Область ПрограммныйИнтерфейс

// Отрабатывает событие регистрации входящего документа: если входящий документ создан
//  на основании входящего письма, тогда создаёт исходящее письмо в ответ на входящее и сообщает
//  отправителю письма о регистрации входящего документа
//
// Параметры:
//  Событие					 - 	 - обрабатываемое бизнес событие
//  ОбработчикПредставление	 - Строка - представление обработчика событий (для журнала регистрации)
//
Процедура ОбработатьСобытиеСообщитьОтправителюОРегистрацииВходящегоДокумента(Знач Событие, Знач ОбработчикПредставление) Экспорт
	
	Контекст = "ИТГ_БизнесСобытия.ОбработатьСобытиеСообщитьОтправителюОРегистрацииВходящегоДокумента";
	
	ИспользоватьВстроеннуюПочту = ПолучитьФункциональнуюОпцию("ИспользованиеВстроеннойПочты");
	ОбщегоНазначенияКлиентСервер.Проверить(
		ИспользоватьВстроеннуюПочту,
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Обработчик событий ""%1"" предназначен для обработки событий регистрации
				|и перерегистрации входящих документов. 
				|Для его работы необходимо встроенная почта. 
				|Отключите данный обработчик или включите встроенную почту документооборота'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление),
		Контекст);
	
	ОбщегоНазначенияКлиентСервер.Проверить(
		Событие.ВидСобытия = Справочники.ВидыБизнесСобытий.РегистрацияВходящегоДокумента
		Или Событие.ВидСобытия = Справочники.ВидыБизнесСобытий.ПеререгистрацияВходящегоДокумента,
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Обработчик событий ""%1"" предназначен для обработки событий регистрации
				|и перерегистрации входящих документов. 
				|Текущее событие имеет вид ""%2"". 
				|Исправьте подписку на события для обработчика ""%1""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление, Строка(Событие.ВидСобытия)),
		Контекст);
		
	ОбщегоНазначенияКлиентСервер.Проверить(
		ДелопроизводствоКлиентСервер.ЭтоВходящийДокумент(Событие.Источник),
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Обработчик событий ""%1"" предназначен для обработки событий регистрации
				|и перерегистрации входящих документов. 
				|Источник события не является входящим документом и имеет тип ""%2""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление, Метаданные.НайтиПоТипу(ТипЗнч(Событие.Источник)).ПолноеИмя()),
		Контекст);
		
	ВходящийДокумент = Событие.Источник;
	
	РеквизитыДокумента = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ВходящийДокумент,
		"ДатаРегистрации, РегистрационныйНомер, ИсходящаяДата, ИсходящийНомер");
	
	Если Не ЗначениеЗаполнено(РеквизитыДокумента.РегистрационныйНомер) Тогда
		Возврат;
	КонецЕсли;
	
	ВходящееПисьмо = СвязиДокументов.ПолучитьСвязанныйДокумент(ВходящийДокумент, Справочники.ТипыСвязей.НаОснованииПисьма);
	
	Если ВходящееПисьмо = Неопределено Тогда
		// входящий документ создан не на основании входящего письма
		Возврат;
	КонецЕсли;
	
	ОбщегоНазначенияКлиентСервер.Проверить(
		ВстроеннаяПочтаКлиентСервер.ЭтоВходящееПисьмо(ВходящееПисьмо),
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Тип связи ""%3"" предназначен для связи входящего документа с входящим письмом, 
				|которым документ был переслан.
				|Входящий документ ""%2"" связан указанным типом связи с объектом типа ""%4""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление, Строка(ВходящийДокумент),
			Строка(Справочники.ТипыСвязей.ПересланоПисьмом), Метаданные.НайтиПоТипу(ТипЗнч(ВходящееПисьмо)).ПолноеИмя()),
		Контекст);
		
	ЗаписьЖурналаРегистрации("ОбработкаБизнесСобытий.СообщитьОтправителюОРегистрацииВходящегоДокумента",
		УровеньЖурналаРегистрации.Примечание,
		Метаданные.Справочники.ВходящиеДокументы,
		ВходящийДокумент,
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Начата обработка события регистрации входящего документа ""%3"" обработчиком ""%1"". 
				|Контекст ""%2""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление, Контекст, Строка(ВходящийДокумент)));
			
	// проверим, если письмо переслано нашим пользователем - найдём исходное письмо
	// Возвращает идентификаторы письма из заголовка
	ПересланнаяКопияВходящегоПисьма = ВходящееПисьмо;
	ИсходноеВходящееПисьмо = ИТГ_ВстроеннаяПочтаСервер.ПолучитьВходящееПисьмоОснование(ВходящееПисьмо);
	Если ЗначениеЗаполнено(ИсходноеВходящееПисьмо) Тогда
		ВходящееПисьмо = ИсходноеВходящееПисьмо;
	КонецЕсли;
	
	Если Не ИТГ_БизнесСобытияПереопределяемый.ЭтоВходящееПисьмоОтКорреспондента(ВходящееПисьмо) Тогда
		Возврат;
	КонецЕсли;
	
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Автоматический);
	Попытка
		
		Если ЗначениеЗаполнено(ИсходноеВходящееПисьмо) Тогда
			// удаляем связь с копией письма и устанавливаем связь с исходным письмом
			СвязиДокументов.УстановитьСвязь(
				ВходящийДокумент,
				ПересланнаяКопияВходящегоПисьма,
				ИсходноеВходящееПисьмо,
				Справочники.ТипыСвязей.НаОснованииПисьма, , ,
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Связь заменена обработчиком события ""%1"". 
						|Контекст ""%2""'",
						ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
					ОбработчикПредставление, Контекст));

			ЗаписьЖурналаРегистрации("ОбработкаБизнесСобытий.СообщитьОтправителюОРегистрацииВходящегоДокумента",
				УровеньЖурналаРегистрации.Предупреждение,
				Метаданные.Справочники.ВходящиеДокументы,
				ВходящийДокумент,
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Обработчиком ""%1"" события регистрации входящего документа ""%3"" 
						|заменена связь к письму-основанию.
						|Исходное связанное письмо (""%4"") являлось пересланной копией.
						|Контекст ""%2""'",
						ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
					ОбработчикПредставление, Контекст, Строка(ВходящийДокумент), Строка(ПересланнаяКопияВходящегоПисьма)),
				РежимТранзакцииЗаписиЖурналаРегистрации.Транзакционная);
				
		КонецЕсли;
		
		ГенерацияСообщенияОтправителюРазрешена = Истина;
		Если ГенерацияСообщенияОтправителюРазрешена Тогда 
			ЗначениеAutoReply = ВстроеннаяПочтаСервер.ПолучитьЗначениеПоляИзЗаголовкаПисьма(ВходящееПисьмо.ВнутреннийЗаголовок,
				"X-1C-AutoReply");
			Если ЗначениеAutoReply = "true" Тогда 
				ГенерацияСообщенияОтправителюРазрешена = Ложь;
			КонецЕсли;
		КонецЕсли;
		Если ГенерацияСообщенияОтправителюРазрешена Тогда 
			ЗначениеAutoResponseSuppress = ВстроеннаяПочтаСервер.ПолучитьЗначениеПоляИзЗаголовкаПисьма(ВходящееПисьмо.ВнутреннийЗаголовок,
				"X-Auto-Response-Suppress");
			ЗначенияAutoResponseSuppress = СтрРазделить(ЗначениеAutoResponseSuppress, ", ", Ложь);
			Если ЗначенияAutoResponseSuppress.Найти("RN") <> Неопределено 
				Или ЗначенияAutoResponseSuppress.Найти("AutoReply") <> Неопределено 
			Тогда 
				ГенерацияСообщенияОтправителюРазрешена = Ложь;
			КонецЕсли;
		КонецЕсли;
		
		ИсходящееПисьмо = Документы.ИсходящееПисьмо.СоздатьДокумент();
		ЗначенияЗаполнения = Новый Структура;
		ЗначенияЗаполнения.Вставить("Команда", "Ответить");
		ЗначенияЗаполнения.Вставить("Письмо", ВходящееПисьмо);
		ИсходящееПисьмо.Заполнить(ЗначенияЗаполнения);
		
		ИсходящееПисьмо.УчетнаяЗапись = ВходящееПисьмо.УчетнаяЗапись;
		
		ИспользованныйШаблон = Неопределено;
		СодержаниеПисьмаДоАвтоответа = ВстроеннаяПочтаСервер.СформироватьТекстИсходящегоПисьма(
			ВходящееПисьмо,
			Перечисления.ТипыТекстовПочтовыхСообщений.ПростойТекст,
			КодировкаТекста.UTF8,
			Перечисления.ТипыОтвета.ОтветНаПисьмо,
			ИспользованныйШаблон);
			
		// сформированный ответ содержит подпись для пользователя, от имени которого запущено фоновое задание,
		// т.е. для администратора. Установим подпись для получателя входящего письма.
		//ШаблонПодписи = ВстроеннаяПочтаСерверПовтИсп.ПолучитьПерсональнуюНастройку("ПодписьПриОтветеИПересылке");
		ШаблонПодписи = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
			"ВстроеннаяПочта",
			"ПодписьПриОтветеИПересылке",
			Неопределено, ,
			ИсходящееПисьмо.Папка.Ответственный);
		Подпись = "";
		
		Если ТипЗнч(ШаблонПодписи) = Тип("СправочникСсылка.ШаблоныТекстов")	И ЗначениеЗаполнено(ШаблонПодписи) Тогда
			Подпись = Справочники.ШаблоныТекстов.ПолучитьТекстШаблона(ШаблонПодписи);
		КонецЕсли;
			
		// TODO: использовать шаблоны текстов из дополнительных настроек программы!
		// но при текущем режиме совместимости добавить константы невозможно...
		ШаблонАвтоответа = ?(ЗначениеЗаполнено(РеквизитыДокумента.ИсходящаяДата),
			Справочники.ШаблоныТекстов.НайтиСоздать_ШаблонАвтоответаПриРегистрацииВходящегоДокументаСНомеромИсходящего(),
			Справочники.ШаблоныТекстов.НайтиСоздать_ШаблонАвтоответаПриРегистрацииВходящегоДокумента());
		ШаблонАвтоответаТекст = Справочники.ШаблоныТекстов.ПолучитьТекстШаблона(ШаблонАвтоответа);
		
		ТекстАвтоответа = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонАвтоответаТекст,
			Формат(РеквизитыДокумента.ДатаРегистрации, "ДЛФ=Д"), РеквизитыДокумента.РегистрационныйНомер,
			Формат(РеквизитыДокумента.ИсходящаяДата, "ДЛФ=Д"), РеквизитыДокумента.ИсходящийНомер);
			
		СодержаниеПисьма = ТекстАвтоответа + Символы.ПС + Подпись + Символы.ПС + СодержаниеПисьмаДоАвтоответа;
		ИсходящееПисьмо.УстановитьСодержаниеПисьма(СодержаниеПисьма);
		
		ИсходящееПисьмо.ПодготовленоКОтправке = ТекущаяДатаСеанса();
		ИсходящееПисьмо.ДополнительныеСвойства.Вставить("ВыполняетсяОтправка", Истина);
		
		ИсходящееПисьмо.Записать();
		
		// В результате при отправке ответа добавляется заголовок X-1C-AutoReply со значением true.
		// Это важно, если и с другой стороны 1С:ДО.
		Для Каждого Получатель Из ИсходящееПисьмо.ПолучателиПисьма Цикл
			РегистрыСведений.АвтоматическиеОтветыПоАдресам.ДобавитьЗапись(, Получатель.Адресат.Адрес, ИсходящееПисьмо.Ссылка);
		КонецЦикла;
		
		ВстроеннаяПочтаСервер.ОбновитьВеткуПереписки(ИсходящееПисьмо.Ссылка);
							
		СвязиДокументов.УстановитьСвязь(
			ИсходящееПисьмо.Ссылка,
			Неопределено,
			ВходящееПисьмо,
			Справочники.ТипыСвязей.ПисьмоОтправленоВОтветНа, , ,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Связь установлена обработчиком обработчиком ""%1"". 
					|Контекст ""%2""'",
					ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				ОбработчикПредставление, Контекст));
				
		ЗаписьЖурналаРегистрации("ОбработкаБизнесСобытий.СообщитьОтправителюОРегистрацииВходящегоДокумента",
			УровеньЖурналаРегистрации.Информация,
			Метаданные.Документы.ИсходящееПисьмо,
			ИсходящееПисьмо.Ссылка,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Отправлен автоответ о регистрации входящего документа ""%3"" обработчиком ""%1"". 
					|Контекст ""%2""'",
					ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				ОбработчикПредставление, Контекст, Строка(ВходящийДокумент)),
			РежимТранзакцииЗаписиЖурналаРегистрации.Транзакционная);
			
		ЗафиксироватьТранзакцию();
		
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	ЗаписьЖурналаРегистрации("ОбработкаБизнесСобытий.СообщитьОтправителюОРегистрацииВходящегоДокумента",
		УровеньЖурналаРегистрации.Примечание,
		Метаданные.Справочники.ВходящиеДокументы,
		ВходящийДокумент,
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Завершена обработка события регистрации входящего документа ""%3"" обработчиком ""%1"". 
				|Контекст ""%2""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление, Контекст, Строка(ВходящийДокумент)));
			
КонецПроцедуры	

// Отрабатывает событие регистрации входящего документа: если входящий документ создан
//  на основании входящего письма от сканера, тогда удаляет письмо-основание
//  и удаляет связь с ним
//
// Параметры:
//  Событие					 - 	 - обрабатываемое бизнес событие
//  ОбработчикПредставление	 - Строка - представление обработчика событий (для журнала регистрации)
//
Процедура ОбработатьСобытиеУдалитьПисьмоОснованиеОтСканера(Знач Событие, Знач ОбработчикПредставление) Экспорт
	
	Контекст = "ИТГ_БизнесСобытия.ОбработатьСобытиеУдалитьПисьмоОснованиеОтСканера";
	
	ИспользоватьВстроеннуюПочту = ПолучитьФункциональнуюОпцию("ИспользованиеВстроеннойПочты");
	ОбщегоНазначенияКлиентСервер.Проверить(
		ИспользоватьВстроеннуюПочту,
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Обработчик событий ""%1"" предназначен для обработки событий регистрации
				|входящих документов. 
				|Для его работы необходимо встроенная почта. 
				|Отключите данный обработчик или включите встроенную почту документооборота'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление),
		Контекст);
	
	ОбщегоНазначенияКлиентСервер.Проверить(
		Событие.ВидСобытия = Справочники.ВидыБизнесСобытий.РегистрацияВходящегоДокумента,
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Обработчик событий ""%1"" предназначен для обработки событий регистрации
				|входящих документов. 
				|Текущее событие имеет вид ""%2"". 
				|Исправьте подписку на события для обработчика ""%1""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление, Строка(Событие.ВидСобытия)),
		Контекст);
		
	ОбщегоНазначенияКлиентСервер.Проверить(
		ДелопроизводствоКлиентСервер.ЭтоВходящийДокумент(Событие.Источник),
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Обработчик событий ""%1"" предназначен для обработки событий регистрации
				|входящих документов. 
				|Источник события не является входящим документом и имеет тип ""%2""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление, Метаданные.НайтиПоТипу(ТипЗнч(Событие.Источник)).ПолноеИмя()),
		Контекст);
		
	ВходящийДокумент = Событие.Источник;
	
	РеквизитыДокумента = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(ВходящийДокумент,
		"ДатаРегистрации, РегистрационныйНомер, ИсходящаяДата, ИсходящийНомер");
	
	Если Не ЗначениеЗаполнено(РеквизитыДокумента.РегистрационныйНомер) Тогда
		Возврат;
	КонецЕсли;
	
	ВходящееПисьмо = СвязиДокументов.ПолучитьСвязанныйДокумент(ВходящийДокумент, Справочники.ТипыСвязей.НаОснованииПисьма);
	
	Если ВходящееПисьмо = Неопределено Тогда
		// входящий документ создан не на основании входящего письма
		Возврат;
	КонецЕсли;
	
	ОбщегоНазначенияКлиентСервер.Проверить(
		ВстроеннаяПочтаКлиентСервер.ЭтоВходящееПисьмо(ВходящееПисьмо),
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Тип связи ""%3"" предназначен для связи входящего документа с входящим письмом, 
				|которым документ был переслан.
				|Входящий документ ""%2"" связан указанным типом связи с объектом типа ""%4""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление, Строка(ВходящийДокумент),
			Строка(Справочники.ТипыСвязей.ПересланоПисьмом), Метаданные.НайтиПоТипу(ТипЗнч(ВходящееПисьмо)).ПолноеИмя()),
		Контекст);
		
	ЗаписьЖурналаРегистрации("ОбработкаБизнесСобытий.УдалитьПисьмоОснованиеОтСканера",
		УровеньЖурналаРегистрации.Примечание, , ,
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Начата обработка события регистрации входящего документа ""%3"" обработчиком ""%1"". 
				|Контекст ""%2""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление, Контекст, Строка(ВходящийДокумент)));
			
	Если Не ИТГ_БизнесСобытияПереопределяемый.ЭтоВходящееПисьмоОтСканера(ВходящееПисьмо) Тогда
		Возврат;
	КонецЕсли;
	
	НачатьТранзакцию(РежимУправленияБлокировкойДанных.Автоматический);
	Попытка
							
		СвязиДокументов.УдалитьСвязь(ВходящийДокумент, ВходящееПисьмо, Справочники.ТипыСвязей.НаОснованииПисьма);
		
		ВходящееПисьмоОбъект = ВходящееПисьмо.ПолучитьОбъект();
		ВходящееПисьмоОбъект.УстановитьПометкуУдаления(Истина);
				
		ЗаписьЖурналаРегистрации("ОбработкаБизнесСобытий.УдалитьПисьмоОснованиеОтСканера",
			УровеньЖурналаРегистрации.Информация, ,
			ВходящийДокумент,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Обработчиком ""%1"" удалено письмо-основание документа ""%3"", полученное от сканера. 
					|Контекст ""%2""'",
					ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				ОбработчикПредставление, Контекст, Строка(ВходящийДокумент)),
			РежимТранзакцииЗаписиЖурналаРегистрации.Транзакционная);
			
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	ЗаписьЖурналаРегистрации("ОбработкаБизнесСобытий.УдалитьПисьмоОснованиеОтСканера",
		УровеньЖурналаРегистрации.Примечание, , ,
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Завершена обработка события регистрации входящего документа ""%3"" обработчиком ""%1"". 
				|Контекст ""%2""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление, Контекст, Строка(ВходящийДокумент)));
	
КонецПроцедуры	

// Отрабатывает событие изменения внутреннего документа:
//  если состояние документа - не подписан, а документ подписан,
//  устанавливат состояние Подписан.
//
// Параметры:
//  Событие					 - 	 - обрабатываемое бизнес событие
//  ОбработчикПредставление	 - Строка - представление обработчика событий (для журнала регистрации)
//
Процедура ОбработатьСобытиеУстановитьСостояниеПодписан(Знач Событие, Знач ОбработчикПредставление) Экспорт
	
	Контекст = "ИТГ_БизнесСобытия.ОбработатьСобытиеУстановитьСостояниеПодписан";
	
	ИспользоватьСостоянияДокументов = ПолучитьФункциональнуюОпцию("ИспользоватьСостоянияДокументов");
	ОбщегоНазначенияКлиентСервер.Проверить(
		ИспользоватьСостоянияДокументов,
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Обработчик событий ""%1"" предназначен для обработки событий
				|изменения внутренних документов. 
				|Для его работы необходима поддержка состояний документов. 
				|Отключите данный обработчик или включите поддержку состояний документов'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление),
		Контекст);
	
	ИспользоватьВидыВнутреннихДокументов = ПолучитьФункциональнуюОпцию("ИспользоватьВидыВнутреннихДокументов");
	ОбщегоНазначенияКлиентСервер.Проверить(
		ИспользоватьВидыВнутреннихДокументов,
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Обработчик событий ""%1"" предназначен для обработки событий
				|изменения внутренних документов. 
				|Для его работы необходима поддержка видов внутренних документов. 
				|Отключите данный обработчик или включите видов внутренних документов'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление),
		Контекст);
		
	ОбщегоНазначенияКлиентСервер.Проверить(
		Событие.ВидСобытия = Справочники.ВидыБизнесСобытий.ИзменениеВнутреннегоДокумента,
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Обработчик событий ""%1"" предназначен для обработки событий
				|изменения внутренних документов. 
				|Текущее событие имеет вид ""%2"". 
				|Исправьте подписку на события для обработчика ""%1""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление, Строка(Событие.ВидСобытия)),
		Контекст);
		
	ОбщегоНазначенияКлиентСервер.Проверить(
		ДелопроизводствоКлиентСервер.ЭтоВнутреннийДокумент(Событие.Источник),
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Обработчик событий ""%1"" предназначен для обработки событий
				|изменения внутренних документов. 
				|Источник события не является внутренним документом и имеет тип ""%2""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление, Метаданные.НайтиПоТипу(ТипЗнч(Событие.Источник)).ПолноеИмя()),
		Контекст);
		
	Документ = Событие.Источник;
	
	РеквизитыВидаДокумента = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Документ.ВидДокумента,
		"ВариантПодписания, ВестиУчетСторон");
		
	Если РеквизитыВидаДокумента.ВестиУчетСторон
		И (РеквизитыВидаДокумента.ВариантПодписания = Перечисления.ВариантыПодписания.ТолькоКонтрагенты
			Или РеквизитыВидаДокумента.ВариантПодписания = Перечисления.ВариантыПодписания.МыИКонтрагенты)
		Тогда
		
		ЗаписьЖурналаРегистрации("ОбработкаБизнесСобытий.УстановитьСостояниеПодписан",
			УровеньЖурналаРегистрации.Примечание, , ,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Начата обработка события изменения внутреннего документа ""%3"" обработчиком ""%1"". 
					|Контекст ""%2""'",
					ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				ОбработчикПредставление, Контекст, Строка(Документ)));
				
		ДокументПодписан = РаботаСПодписямиДокументов.ДокументПодписанСторонами(Документ.Стороны, РеквизитыВидаДокумента.ВариантПодписания);
		СостояниеДокумента = Делопроизводство.ПолучитьСостояниеДокумента(Документ, "СостояниеПодписание");
		
		Если ДокументПодписан Тогда 
			Если СостояниеДокумента <> Перечисления.СостоянияДокументов.Подписан Тогда 
				
				Делопроизводство.ЗаписатьСостояниеДокумента(
					Документ,
					Неопределено,
					Перечисления.СостоянияДокументов.Подписан,
					Событие.Автор);
					
				ЗаписьЖурналаРегистрации("ОбработкаБизнесСобытий.УстановитьСостояниеПодписан",
					УровеньЖурналаРегистрации.Информация, , ,
					СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Изменено состояние внутреннего документа ""%3"" обработчиком ""%1"". 
							|Документ фактически подписан, а состояние документа содержало неверные сведения. 
							|Контекст ""%2""'",
							ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
						ОбработчикПредставление, Контекст, Строка(Документ)));
						
			КонецЕсли;
		Иначе 
			Если СостояниеДокумента = Перечисления.СостоянияДокументов.Подписан Тогда 
				
				Делопроизводство.ОчиститьСостояниеДокумента(
					Документ,
					Перечисления.СостоянияДокументов.Подписан);
					
				ЗаписьЖурналаРегистрации("ОбработкаБизнесСобытий.УстановитьСостояниеПодписан",
					УровеньЖурналаРегистрации.Информация, , ,
					СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Изменено состояние внутреннего документа ""%3"" обработчиком ""%1"". 
							|Документ фактически не подписан, а состояние документа содержало неверные сведения. 
							|Контекст ""%2""'",
							ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
						ОбработчикПредставление, Контекст, Строка(Документ)));
						
			КонецЕсли;
		КонецЕсли;
		
		ЗаписьЖурналаРегистрации("ОбработкаБизнесСобытий.УстановитьСостояниеПодписан",
			УровеньЖурналаРегистрации.Примечание, , ,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Завершена обработка события изменения внутреннего документа ""%3"" обработчиком ""%1"". 
					|Контекст ""%2""'",
					ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				ОбработчикПредставление, Контекст, Строка(Документ)));
				
	КонецЕсли;
		
КонецПроцедуры	

// Отрабатывает событие изменения документа:
//  Добавляет к заголовку документа "(удалён)" при установке пометки на удаление.
//  И удаляет указанный префикс при снятии пометки на удаление.
//
// Параметры:
//  Событие					 - 	 - обрабатываемое бизнес событие
//  ОбработчикПредставление	 - Строка - представление обработчика событий (для журнала регистрации)
//
Процедура ОбработатьСобытиеУстановитьПометкуУдаленияДокумента(Знач Событие, Знач ОбработчикПредставление) Экспорт

	Контекст = "ИТГ_БизнесСобытия.ОбработатьСобытиеУстановитьПометкуУдаленияДокумента";

	ОбщегоНазначенияКлиентСервер.Проверить(
		Событие.ВидСобытия = Справочники.ВидыБизнесСобытий.ИзменениеВнутреннегоДокумента
		Или Событие.ВидСобытия = Справочники.ВидыБизнесСобытий.ИзменениеВходящегоДокумента
		Или Событие.ВидСобытия = Справочники.ВидыБизнесСобытий.ИзменениеИсходящегоДокумента,
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Обработчик событий ""%1"" предназначен для обработки событий
				|изменения документов. 
				|Текущее событие имеет вид ""%2"". 
				|Исправьте подписку на события для обработчика ""%1""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление, Строка(Событие.ВидСобытия)),
		Контекст);

	ОбщегоНазначенияКлиентСервер.Проверить(
		ДелопроизводствоКлиентСервер.ЭтоСсылкаНаДокумент(Событие.Источник),
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Обработчик событий ""%1"" предназначен для обработки событий
				|изменения документов. 
				|Источник события не является документом и имеет тип ""%2""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление, Метаданные.НайтиПоТипу(ТипЗнч(Событие.Источник)).ПолноеИмя()),
		Контекст);

	Документ = Событие.Источник;

	// TODO: Возможно, стоит уйти от использования константы "(удалён)" на шаблоны текста
	ПрефиксЗаголовкаПомеченногоНаУдалениеДокумента = НСтр(
		"ru = '(удалён)'",
		ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка());
	ЗаголовокДокументаСодержитПрефикс = СтрНачинаетсяС(Документ.Заголовок,
		ПрефиксЗаголовкаПомеченногоНаУдалениеДокумента);

	Если Документ.ПометкаУдаления <> ЗаголовокДокументаСодержитПрефикс Тогда

		ЗаписьЖурналаРегистрации("ОбработкаБизнесСобытий.УстановитьПометкуУдаленияДокумента",
			УровеньЖурналаРегистрации.Примечание, , ,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Начата обработка события изменения документа ""%3"" обработчиком ""%1"". 
					|Контекст ""%2""'",
					ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				ОбработчикПредставление, Контекст, Строка(Документ)));

		НачатьТранзакцию(РежимУправленияБлокировкойДанных.Автоматический);
		Попытка

			ДокументОбъект = Документ.ПолучитьОбъект();
			Если Документ.ПометкаУдаления Тогда
				ДокументОбъект.Заголовок = ПрефиксЗаголовкаПомеченногоНаУдалениеДокумента + " " +
					ДокументОбъект.Заголовок;
			Иначе
				ДокументОбъект.Заголовок = СокрЛП(Прав(ДокументОбъект.Заголовок,
					СтрДлина(ДокументОбъект.Заголовок) - СтрДлина(ПрефиксЗаголовкаПомеченногоНаУдалениеДокумента)));
			КонецЕсли;
			ДокументОбъект.Записать();

			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ВызватьИсключение;
		КонецПопытки;

		ЗаписьЖурналаРегистрации("ОбработкаБизнесСобытий.УстановитьПометкуУдаленияДокумента",
			УровеньЖурналаРегистрации.Информация, , ,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Изменено наименование документа ""%3"" обработчиком ""%1"". 
					|Добавлен / удалён префикс в соответствии с пометкой удаления. 
					|Контекст ""%2""'",
					ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				ОбработчикПредставление, Контекст, Строка(Документ)));

		ЗаписьЖурналаРегистрации("ОбработкаБизнесСобытий.УстановитьПометкуУдаленияДокумента",
			УровеньЖурналаРегистрации.Примечание, , ,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Завершена обработка события изменения документа ""%3"" обработчиком ""%1"". 
					|Контекст ""%2""'",
					ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				ОбработчикПредставление, Контекст, Строка(Документ)));

	КонецЕсли;

КонецПроцедуры	

// Отрабатывает событие изменения документа:
//  При установке пометки на удаление на документе прерывает все процессы,
//  в которых он был единственным основным предметом.
//
// Параметры:
//  Событие					 - 	 - обрабатываемое бизнес событие
//  ОбработчикПредставление	 - Строка - представление обработчика событий (для журнала регистрации)
//
Процедура ОбработатьСобытиеУстановитьПометкуУдаленияДокументаИПрерватьПроцессы(Знач Событие, Знач ОбработчикПредставление) Экспорт

	Контекст = "ИТГ_БизнесСобытия.ОбработатьСобытиеУстановитьПометкуУдаленияДокументаИПрерватьПроцессы";
	ИдентификаторСобытия = "ОбработкаБизнесСобытий.ПрерватьПроцессыПоДокументуПриУстановкеПометкиУдаления";

	ОбщегоНазначенияКлиентСервер.Проверить(
		Событие.ВидСобытия = Справочники.ВидыБизнесСобытий.ИзменениеВнутреннегоДокумента
		Или Событие.ВидСобытия = Справочники.ВидыБизнесСобытий.ИзменениеВходящегоДокумента
		Или Событие.ВидСобытия = Справочники.ВидыБизнесСобытий.ИзменениеИсходящегоДокумента,
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Обработчик событий ""%1"" предназначен для обработки событий
				|изменения документов. 
				|Текущее событие имеет вид ""%2"". 
				|Исправьте подписку на события для обработчика ""%1""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление, Строка(Событие.ВидСобытия)),
		Контекст);

	ОбщегоНазначенияКлиентСервер.Проверить(
		ДелопроизводствоКлиентСервер.ЭтоСсылкаНаДокумент(Событие.Источник),
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Обработчик событий ""%1"" предназначен для обработки событий
				|изменения документов. 
				|Источник события не является документом и имеет тип ""%2""'",
				ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
			ОбработчикПредставление, Метаданные.НайтиПоТипу(ТипЗнч(Событие.Источник)).ПолноеИмя()),
		Контекст);

	Документ = Событие.Источник;
	
	РеквизитыДокумента = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Документ,
		"ПометкаУдаления");
	
	Если РеквизитыДокумента.ПометкаУдаления Тогда

		ЗаписьЖурналаРегистрации(ИдентификаторСобытия,
			УровеньЖурналаРегистрации.Примечание, , ,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Начата обработка события изменения документа ""%3"" обработчиком ""%1"". 
					|Контекст ""%2""'",
					ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				ОбработчикПредставление, Контекст, Строка(Документ)));
				
		УстановитьПривилегированныйРежим(Истина);
		
		ТекстЗапросаБизнесПроцессов = 
		"ВЫБРАТЬ
		|	ПредметыПроцесса.Ссылка КАК Процесс
		|ИЗ
		|	БизнесПроцесс.%1.Предметы КАК ПредметыПроцесса
		|ГДЕ
		|	ПредметыПроцесса.Предмет = &Предмет
		|	И ПредметыПроцесса.РольПредмета = ЗНАЧЕНИЕ(Перечисление.РолиПредметов.Основной)
		|	И НЕ ПредметыПроцесса.Ссылка.ПометкаУдаления
		|	И НЕ ПредметыПроцесса.Ссылка.Состояние = ЗНАЧЕНИЕ(Перечисление.СостоянияБизнесПроцессов.Прерван)";
		
		ТекстыЗапросовБизнесПроцессов = Новый Массив;
		Для Каждого МетаданныеПроцесса Из Метаданные.БизнесПроцессы Цикл 
			ТекстЗапросаДляТипаПроцессов = СтрШаблон(ТекстЗапросаБизнесПроцессов, МетаданныеПроцесса.Имя);
			ТекстыЗапросовБизнесПроцессов.Добавить(ТекстЗапросаДляТипаПроцессов);
		КонецЦикла;
		РазделительЗапросов = Символы.ПС + Символы.ПС + "ОБЪЕДИНИТЬ ВСЕ" + Символы.ПС + Символы.ПС;
		ТекстЗапроса = СтрСоединить(ТекстыЗапросовБизнесПроцессов, РазделительЗапросов);
		ПараметрыОтбораОсновныхПредметов = Новый Структура("РольПредмета", Перечисления.РолиПредметов.Основной);
		
		Запрос = Новый Запрос();
		Запрос.Текст = ТекстЗапроса;
		Запрос.УстановитьПараметр("Предмет", Документ);
		Выборка = Запрос.Выполнить().Выбрать();
		
		Если Выборка.Количество() > 0 Тогда 
			
			ЗаписьЖурналаРегистрации(ИдентификаторСобытия,
				УровеньЖурналаРегистрации.Примечание, , ,
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Обработчиком ""%1"" обнаружено %4 процесс(ов) для помеченного на удаление документа ""%3"". 
						|Будет предпринята попытка прерывания процессов.
						|Контекст ""%2""'",
						ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
					ОбработчикПредставление, Контекст, Строка(Документ), Строка(Выборка.Количество())));
					
			ПричинаПрерывания = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Основной предмет ""%3"" для данного процесса помечен на удаление.
					|Обработчиком ""%1"" данный процесс прерван. 
					|Контекст ""%2""'",
					ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				ОбработчикПредставление, Контекст, Строка(Документ));

			НачатьТранзакцию(РежимУправленияБлокировкойДанных.Автоматический);
			Попытка
				Пока Выборка.Следующий() Цикл
					Процесс = Выборка.Процесс;
					Если Процесс.Предметы.НайтиСтроки(ПараметрыОтбораОсновныхПредметов).Количество() = 1 Тогда 
						// Прерываем только процессы, у которых помеченный на удаление документ является
						// единственным основным предметом
						БизнесПроцессыИЗадачиВызовСервера.ПрерватьБизнесПроцесс(Процесс, ПричинаПрерывания);
					КонецЕсли;
				КонецЦикла;
				ЗафиксироватьТранзакцию();
			Исключение
				ОтменитьТранзакцию();
				ВызватьИсключение;
			КонецПопытки;

			ЗаписьЖурналаРегистрации(ИдентификаторСобытия,
				УровеньЖурналаРегистрации.Информация, , ,
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Обработчиком ""%1"" прерваны процессы, для которых единственным основным предметом являлся документ ""%3"".
						|Контекст ""%2""'",
						ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
					ОбработчикПредставление, Контекст, Строка(Документ)));

		КонецЕсли;

		ЗаписьЖурналаРегистрации(ИдентификаторСобытия,
			УровеньЖурналаРегистрации.Примечание, , ,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Завершена обработка события изменения документа ""%3"" обработчиком ""%1"". 
					|Контекст ""%2""'",
					ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				ОбработчикПредставление, Контекст, Строка(Документ)));

	КонецЕсли;

КонецПроцедуры	

#КонецОбласти
