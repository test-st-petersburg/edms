"use strict";

module.exports = {
  // Добавим описание на русском языке ко всем типам
  types: [
    {
      value: "build",
      name: "build: Сборка проекта или изменения внешних зависимостей"
    },
    {
      value: "ci",
      name: "ci: Настройка CI и работа со скриптами"
    },
    {
      value: "docs",
      name: "docs: Обновление документации"
    },
    {
      value: "feat",
      name: "feat: Добавление нового функционала"
    },
    {
      value: "fix",
      name: "fix: Исправление ошибок"
    },
    {
      value: "perf",
      name: "perf: Изменения, направленные на улучшение производительности"
    },
    {
      value: "refactor",
      name: "refactor: Правки кода без исправления ошибок или добавления новых функций"
    },
    {
      value: "revert",
      name: "revert: Откат на предыдущие версии"
    },
    {
      value: "style",
      name: "style: Исправления стиля кода"
    },
    {
      value: "test",
      name: "test: Добавление тестов"
    },
    {
      value: "chore",
      name: "chore: Прочие изменения, не влияющие на код"
    }
  ],

  // Область. Она характеризует фрагмент кода, которую затронули изменения
  scopes: [
    { name: "ext" },
    { name: "docs" },
    { name: "design" },
    { name: "git" },
    { name: "commitizen" }
  ],

  // Возможность задать спец ОБЛАСТЬ для определенного типа изменения (пример для 'fix')
  /*
  scopeOverrides: {
    fix: [
      {name: 'merge'},
      {name: 'style'}
    ]
  },
  */

  messages: {
    type: "Какие изменения вы вносите?",
    scope: "Выберите ОБЛАСТЬ, которую вы изменили (опционально):",
    customScope: "Укажите свою ОБЛАСТЬ:",
    subject: "Напишите КОРОТКОЕ описание в ПОВЕЛИТЕЛЬНОМ наклонении:\n",
    body: 'Напишите ПОДРОБНОЕ описание (опционально). Используйте "|" для новой строки:\n',
    breaking: "Список BREAKING CHANGES (опционально):\n",
    footer: "Место для метаданных (issues, ссылок, например: 'Closed: #3').\n",
    confirmCommit: "Вас устраивает получившиеся сообщение?"
  },

  allowCustomScopes: false,
  allowBreakingChanges: ['feat', 'fix'],
  footerPrefix: "МЕТАДАННЫЕ:",
  subjectLimit: 72
};
