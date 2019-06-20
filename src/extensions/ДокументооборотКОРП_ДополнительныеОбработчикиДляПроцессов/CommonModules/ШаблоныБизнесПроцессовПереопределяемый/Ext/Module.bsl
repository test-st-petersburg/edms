﻿#Область ПрограммныйИнтерфейс

// Возвращает список пользовательских функций для автоподстановки исполнителей в шаблонах документов
//
// Параметры:
//	ИменаПредметовДляФункций - массив - массив имен предметов для функций автоподстановки
//
&Вместо("ПолучитьСписокДоступныхФункций")
Функция ИТГ_ПолучитьСписокДоступныхФункций(ИменаПредметовДляФункций)
	
	ДоступныеФункции = ПродолжитьВызов(ИменаПредметовДляФункций);
	
	Если ИменаПредметовДляФункций <> Неопределено Тогда
		Если ИменаПредметовДляФункций.Количество() > 0 Тогда
		
			Для Каждого ИмяПредмета Из ИменаПредметовДляФункций Цикл 
				
				ДоступныеФункции.Добавить("ИТГ_ШаблоныБизнесПроцессов.ДелопроизводительПодразделенияДокумента(Объект, ИмяПредмета)",
					СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '%1.Делопроизводитель подразделения, осуществляющего делопроизводство по документу'"), Строка(ИмяПредмета)));
					
			КонецЦикла;
		
		КонецЕсли;
	КонецЕсли;
	
	Возврат ДоступныеФункции;

КонецФункции

#КонецОбласти
