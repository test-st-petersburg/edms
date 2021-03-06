﻿#Область ПрограммныйИнтерфейс

// Проверяет, находится ли руководитель подразделения, указанного в документе,
//  в числе исполнителей задач по документу, как по основному предмету
//  (только по процессам исполнения, рассмотрения, ознакомления).
//  Применяется в условиях маршрутизации процессов.
//
// Параметры:
//  Документ - СправочникСсылка	 - ссылка на внутренний либо входящий документ
// 
// Возвращаемое значение:
//  Булево - Истина, если документ на исполнении, Ложь - если нет
//
Функция ПроверитьРуководительПодразделенияВЧислеИсполнителей(Знач Документ) Экспорт
		
	Контекст = "ИТГ_РаботаСУсловиямиМаршрутизации.ПроверитьРуководительПодразделенияВЧислеИсполнителей";
	
	ОбщегоНазначенияКлиентСервер.Проверить(
		ДелопроизводствоКлиентСервер.ЭтоСсылкаНаДокумент(Документ),
		НСтр("ru = 'Недопустимое значение параметра Документ, 
			|Ожидалась ссылка на документ'",
			ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
		Контекст);
		
	РуководительПодразделения = ИТГ_ШаблоныБизнесПроцессов.ПолучитьРуководителяПодразделенияДокумента(Документ);
	
	Если Не ЗначениеЗаполнено(РуководительПодразделения) Тогда
		Возврат Ложь;
	КонецЕсли;
	
	РуководительНайденВЧислеИсполнителей = Ложь;
	
	Если ТипЗнч(РуководительПодразделения) = Тип("СправочникСсылка.ПолныеРоли") Тогда
		РуководителиПодразделения = РегистрыСведений.ИсполнителиЗадач.ИсполнителиРоли(РуководительПодразделения);
	Иначе
		РуководителиПодразделения = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(РуководительПодразделения);
	КонецЕсли;
	
	АктивныеИсполнители = ИТГ_ШаблоныБизнесПроцессов.ПолучитьИсполнителейДокументаАктивных(Документ);
	Для Каждого Руководитель Из РуководителиПодразделения Цикл
		Для Каждого Исполнитель Из АктивныеИсполнители Цикл
			Если ТипЗнч(Исполнитель) = Тип("СправочникСсылка.ПолныеРоли") Тогда
				РуководительНайденВЧислеИсполнителей = РегистрыСведений.ИсполнителиЗадач.ИсполнителиРоли(Исполнитель).Найти(Руководитель) <> Неопределено;
			Иначе
				РуководительНайденВЧислеИсполнителей = (Руководитель = Исполнитель);
			КонецЕсли;
			Если РуководительНайденВЧислеИсполнителей Тогда
				Прервать;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Возврат РуководительНайденВЧислеИсполнителей;
	
КонецФункции

// Проверяет, подписан ли документ.
// Применяется в условиях маршрутизации процессов.
//
// Параметры:
//  Документ - СправочникСсылка	 - ссылка на внутренний либо исходящий документ
// 
// Возвращаемое значение:
//  Булево
//
Функция ПроверитьДокументПодписанНами(Знач Документ) Экспорт
		
	Контекст = "ИТГ_РаботаСУсловиямиМаршрутизации.ПроверитьДокументПодписан";
	
	ДокументПодписан = Ложь;
		
	ОбщегоНазначенияКлиентСервер.Проверить(
		ДелопроизводствоКлиентСервер.ЭтоСсылкаНаДокумент(Документ),
		НСтр("ru = 'Недопустимое значение параметра Документ, 
			|Ожидалась ссылка на документ'",
			ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
		Контекст);
		
	Если ДелопроизводствоКлиентСервер.ЭтоВнутреннийДокумент(Документ) Тогда 
		
		РеквизитыВидаДокумента = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Документ.ВидДокумента,
			"ИспользоватьУтверждение, ВариантПодписания, ИспользоватьПодписание, ВестиУчетСторон");
		
		ОбщегоНазначенияКлиентСервер.Проверить(
			РеквизитыВидаДокумента.ИспользоватьУтверждение Или РеквизитыВидаДокумента.ИспользоватьПодписание,
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Невозможно определить состояние подписи организации на документе ""%1"". 
					|Документы вида ""%2"" не подписываются и не утверждаются должностным лицом организации'",
					ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
				Строка(Документ), Строка(Документ.ВидДокумента)),
			Контекст);
			
		Если РеквизитыВидаДокумента.ВестиУчетСторон Тогда
			
			ОбщегоНазначенияКлиентСервер.Проверить(
				РеквизитыВидаДокумента.ВариантПодписания = Перечисления.ВариантыПодписания.ТолькоМы
				Или РеквизитыВидаДокумента.ВариантПодписания = Перечисления.ВариантыПодписания.МыИКонтрагенты,
				СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
					НСтр("ru = 'Невозможно определить состояние подписи организации на документе ""%1"". 
						|Документы вида ""%2"" не подписываются должностным лицом организации'",
						ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
					Строка(Документ), Строка(Документ.ВидДокумента)),
				Контекст);
				
			ДокументПодписан = РаботаСПодписямиДокументов.ДокументПодписанСторонами(Документ.Стороны, Перечисления.ВариантыПодписания.ТолькоМы);
			
		ИначеЕсли РеквизитыВидаДокумента.ИспользоватьУтверждение Тогда 
			
			ГрифыУтверждения = Документ.ГрифыУтверждения.Выгрузить();
			ГрифыУтверждения.Свернуть("Результат");
			ДокументПодписан = ГрифыУтверждения.Количество() > 0;
			
			Для Каждого Гриф Из ГрифыУтверждения Цикл
				Если Гриф.Результат = Перечисления.РезультатыУтверждения.НеУтверждено
					Или Не ЗначениеЗаполнено(Гриф.Результат) Тогда
					ДокументПодписан = Ложь;
					Прервать;
				КонецЕсли;
			КонецЦикла;	
			
		ИначеЕсли РеквизитыВидаДокумента.ИспользоватьПодписание Тогда 
			
			ДокументПодписан = Документ.РезультатПодписания = Перечисления.РезультатыПодписания.Подписан;
			
		КонецЕсли;
		
	ИначеЕсли ДелопроизводствоКлиентСервер.ЭтоИсходящийДокумент(Документ) Тогда
			
		ДокументПодписан = ЗначениеЗаполнено(Документ.Подписал);
		
	КонецЕсли;
	
	Возврат ДокументПодписан;
			
КонецФункции

// Проверяет, зарегистрирован ли документ пользователем,
//  являющимся исполнителем роли "Регистратор переписки отправителя",
//  возвращённой одноимённой автоподстановкой.
//  Применяется в условиях маршрутизации процессов.
//
// Параметры:
//  Документ - СправочникСсылка	 - ссылка на внутренний либо входящий документ
// 
// Возвращаемое значение:
//  Булево - 
//
Функция ПроверитьЗарегистрированНеРегистраторомПерепискиОтправителя(Знач Документ) Экспорт
		
	Контекст = "ИТГ_РаботаСУсловиямиМаршрутизации.ПроверитьЗарегистрированНеРегистраторомПерепискиОтправителя";
	
	ОбщегоНазначенияКлиентСервер.Проверить(
		ДелопроизводствоКлиентСервер.ЭтоИсходящийДокумент(Документ)
		Или ДелопроизводствоКлиентСервер.ЭтоВнутреннийДокумент(Документ),
		НСтр("ru = 'Недопустимое значение параметра Документ, 
			|Ожидалась ссылка на внутренний либо исходящий документ'",
			ОбщегоНазначенияКлиентСервер.КодОсновногоЯзыка()),
		Контекст);
		
	РегистраторПереписки = ИТГ_ШаблоныБизнесПроцессов.ПолучитьРегистратораПерепискиОтправителя(Документ);
	Если ТипЗнч(РегистраторПереписки) = Тип("СправочникСсылка.ПолныеРоли") Тогда
		Регистраторы = РегистрыСведений.ИсполнителиЗадач.ИсполнителиРоли(РегистраторПереписки);
	Иначе
		Регистраторы = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(РегистраторПереписки);
	КонецЕсли;
	
	МассивРеквизитовДокумента = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве("Зарегистрировал");
	РеквизитыДокумента = ИТГ_Делопроизводство.ЗначенияРеквизитовДокумента(Документ, МассивРеквизитовДокумента);
	РегистраторДокумента = РеквизитыДокумента.Зарегистрировал;
	РегистраторНайденВЧислеИсполнителейРоли = Регистраторы.Найти(РегистраторДокумента) <> Неопределено;
		
	Возврат Не РегистраторНайденВЧислеИсполнителейРоли;
	
КонецФункции

#КонецОбласти
