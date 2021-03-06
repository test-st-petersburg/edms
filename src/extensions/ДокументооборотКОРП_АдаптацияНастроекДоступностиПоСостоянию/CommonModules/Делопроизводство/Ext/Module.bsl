﻿
&Вместо("ПолучитьНастройкиСостояний")
Функция ИТГ_ПолучитьНастройкиСостояний(ДокументОбъект, Пользователь)
	
	//Результат = ПродолжитьВызов(ДокументОбъект, Пользователь);
	//Возврат Результат;
	
	УстановитьПривилегированныйРежим(Истина);
	
	Если Пользователь = Неопределено Тогда 
		Пользователь = ПользователиКлиентСервер.ТекущийПользователь();
	КонецЕсли;	
	
	Настройки = Новый Массив;
	
	// Настройки для всех видов
	Если ТипЗнч(ДокументОбъект.Ссылка) = Тип("СправочникСсылка.ВходящиеДокументы") Тогда 
		ТипДокумента = Перечисления.ТипыОбъектов.ВходящиеДокументы;
	ИначеЕсли ТипЗнч(ДокументОбъект.Ссылка) = Тип("СправочникСсылка.ИсходящиеДокументы") Тогда 
		ТипДокумента = Перечисления.ТипыОбъектов.ИсходящиеДокументы;
	ИначеЕсли ТипЗнч(ДокументОбъект.Ссылка) = Тип("СправочникСсылка.ВнутренниеДокументы") Тогда 
		ТипДокумента = Перечисления.ТипыОбъектов.ВнутренниеДокументы;
	КонецЕсли;
	
	ВидДокумента = ДокументОбъект.ВидДокумента;
		
	// Настройки для переданного вида документа
	Если ИспользоватьВидыДокументов(ВидДокумента) Тогда 
		
		ВидДокументаИРодители = Делопроизводство.ПолучитьВидДокументаИРодителей(ВидДокумента);
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	НастройкиДоступностиДляВидовДокументов.НастройкаДоступностиПоСостоянию КАК НастройкаДоступностиПоСостоянию
		|ИЗ
		|	РегистрСведений.НастройкиДоступностиДляВидовДокументов КАК НастройкиДоступностиДляВидовДокументов
		|ГДЕ
		|	НЕ НастройкиДоступностиДляВидовДокументов.НастройкаДоступностиПоСостоянию.ПометкаУдаления
		|	И НастройкиДоступностиДляВидовДокументов.НастройкаДоступностиПоСостоянию.ВариантНастройкиДляВидовДокументов = ЗНАЧЕНИЕ(Перечисление.ВариантыНастройкиДоступностиДляВидовДокументов.ДляВыбранныхВидовДокументов)
		|	И НастройкиДоступностиДляВидовДокументов.ВидДокумента В (&ВидДокументаИРодители)
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	НастройкиДоступностиПоСостоянию.Ссылка
		|ИЗ
		|	Справочник.НастройкиДоступностиПоСостоянию КАК НастройкиДоступностиПоСостоянию
		|ГДЕ
		|	НЕ НастройкиДоступностиПоСостоянию.ПометкаУдаления
		|	И НастройкиДоступностиПоСостоянию.ТипДокумента = &ТипДокумента
		|	И НастройкиДоступностиПоСостоянию.ВариантНастройкиДляВидовДокументов = ЗНАЧЕНИЕ(Перечисление.ВариантыНастройкиДоступностиДляВидовДокументов.ДляВсехВидовДокументов)";
		
		Запрос.УстановитьПараметр("ТипДокумента", ТипДокумента);
		Запрос.УстановитьПараметр("ВидДокументаИРодители", ВидДокументаИРодители);
		
		Настройки = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("НастройкаДоступностиПоСостоянию");
		
	Иначе	
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	НастройкиДоступностиПоСостоянию.Ссылка КАК НастройкаДоступностиПоСостоянию
		|ИЗ
		|	Справочник.НастройкиДоступностиПоСостоянию КАК НастройкиДоступностиПоСостоянию
		|ГДЕ
		|	НЕ НастройкиДоступностиПоСостоянию.ПометкаУдаления
		|	И НастройкиДоступностиПоСостоянию.ТипДокумента = &ТипДокумента
		|	И НастройкиДоступностиПоСостоянию.ВариантНастройкиДляВидовДокументов = ЗНАЧЕНИЕ(Перечисление.ВариантыНастройкиДоступностиДляВидовДокументов.ДляВсехВидовДокументов)";
		
		Запрос.УстановитьПараметр("ТипДокумента", ТипДокумента);
		
		Настройки = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("НастройкаДоступностиПоСостоянию");
		
	КонецЕсли;
	
	Результат = Новый Массив;
	Для Каждого Настройка Из Настройки Цикл
		Если Настройка.ПометкаУдаления Тогда 
			Продолжить;
		КонецЕсли;	
		
		Для Каждого Строка Из Настройка.ИспользоватьДля Цикл
			
			Если Не ЗначениеЗаполнено(Строка.Участник) Тогда 
				Продолжить;
			КонецЕсли;	
			
			Если ТипЗнч(Строка.Участник) = Тип("СправочникСсылка.Пользователи") Тогда 
				
				Если Строка.Участник = Пользователь Тогда 
					Результат.Добавить(Настройка);
					Прервать;
				КонецЕсли;	
				
			ИначеЕсли ПользователиДокументооборот.ЭтоКонтейнер(Строка.Участник) Тогда 
				
				СоставКонтейнера = ПользователиДокументооборот.СоставКонтейнера(Строка.Участник);
				Если СоставКонтейнера.Найти(Пользователь) <> Неопределено Тогда 
					Результат.Добавить(Настройка);
					Прервать;
				КонецЕсли;
				
			ИначеЕсли ТипЗнч(Строка.Участник) = Тип("СправочникСсылка.ГруппыДоступа") Тогда 
				
				Запрос = Новый Запрос;
				Запрос.Текст = 
				"ВЫБРАТЬ
				|	ДокументооборотПользователиГруппДоступа.Пользователь
				|ИЗ
				|	РегистрСведений.ДокументооборотПользователиГруппДоступа КАК ДокументооборотПользователиГруппДоступа
				|ГДЕ
				|	ДокументооборотПользователиГруппДоступа.ГруппаДоступа = &ГруппаДоступа";
				Запрос.УстановитьПараметр("ГруппаДоступа", Строка.Участник);
				
				ГруппыДоступа = Запрос.Выполнить().Выгрузить();
				Если ГруппыДоступа.Найти(Пользователь, "Пользователь") <> Неопределено Тогда 
					Результат.Добавить(Настройка);
					Прервать;
				КонецЕсли;
				
			ИначеЕсли ТипЗнч(Строка.Участник) = Тип("Строка") Тогда
				
				ЗначениеАвтоподстановки = ШаблоныДокументов.ПолучитьЗначениеАвтоподстановки(Строка.Участник, ДокументОбъект);
				Если ЗначениеАвтоподстановки = Неопределено Тогда
					Продолжить;
				КонецЕсли;
				
				Если ТипЗнч(ЗначениеАвтоподстановки) = Тип("СправочникСсылка.Пользователи") Тогда
					
					Если ЗначениеАвтоподстановки = Пользователь Тогда 
						Результат.Добавить(Настройка);
						Прервать;
					КонецЕсли;
					
				ИначеЕсли ТипЗнч(ЗначениеАвтоподстановки) = Тип("СправочникСсылка.РабочиеГруппы") Тогда
					
					СоставГруппы = ДокументооборотПраваДоступаПовтИсп.ПолучитьСоставРабочейГруппы(ЗначениеАвтоподстановки);
					Если СоставГруппы.Найти(Пользователь, "Пользователь") <> Неопределено Тогда 
						Результат.Добавить(Настройка);
						Прервать;
					КонецЕсли;
					
				ИначеЕсли ТипЗнч(ЗначениеАвтоподстановки) = Тип("СправочникСсылка.СтруктураПредприятия") Тогда
					
					СоставПодразделения = РаботаСПользователями.ПолучитьПользователейПодразделения(
						ЗначениеАвтоподстановки, Истина);
					Если СоставПодразделения.Найти(Пользователь) <> Неопределено Тогда 
						Результат.Добавить(Настройка);
						Прервать;
					КонецЕсли;
					
				ИначеЕсли ТипЗнч(ЗначениеАвтоподстановки) = Тип("Массив") Тогда 
					
					Для Каждого ЗначениеАвтоподстановкиЭлемент Из ЗначениеАвтоподстановки Цикл
						Если ТипЗнч(ЗначениеАвтоподстановкиЭлемент) = Тип("СправочникСсылка.Пользователи") Тогда
							
							Если ЗначениеАвтоподстановкиЭлемент = Пользователь Тогда 
								Результат.Добавить(Настройка);
								Прервать;
							КонецЕсли;
							
						ИначеЕсли ТипЗнч(ЗначениеАвтоподстановкиЭлемент) = Тип("СправочникСсылка.РабочиеГруппы") Тогда
							
							СоставГруппы = ДокументооборотПраваДоступаПовтИсп.ПолучитьСоставРабочейГруппы(ЗначениеАвтоподстановкиЭлемент);
							Если СоставГруппы.Найти(Пользователь, "Пользователь") <> Неопределено Тогда 
								Результат.Добавить(Настройка);
								Прервать;
							КонецЕсли;
							
						ИначеЕсли ТипЗнч(ЗначениеАвтоподстановкиЭлемент) = Тип("СправочникСсылка.СтруктураПредприятия") Тогда
							
							СоставПодразделения = РаботаСПользователями.ПолучитьПользователейПодразделения(
								ЗначениеАвтоподстановкиЭлемент, Истина);
							Если СоставПодразделения.Найти(Пользователь) <> Неопределено Тогда 
								Результат.Добавить(Настройка);
								Прервать;
							КонецЕсли;
							
						Иначе
							
							ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
								НСтр("ru = 'Функция автоподстановки %1 вернула некорректное значение %2.'"),
								Строка(Строка.Участник),
								Строка(ЗначениеАвтоподстановкиЭлемент));
							
							ВызватьИсключение ТекстСообщения;
							
						КонецЕсли;
					КонецЦикла;
					
				Иначе
					
					ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
						НСтр("ru = 'Функция автоподстановки %1 вернула некорректное значение %2.'"),
						Строка(Строка.Участник),
						Строка(ЗначениеАвтоподстановкиЭлемент));
					
					ВызватьИсключение ТекстСообщения;
					
				КонецЕсли;	
				
			КонецЕсли;	
			
		КонецЦикла;	
		
	КонецЦикла;	
	
	Возврат Результат;
	
КонецФункции
