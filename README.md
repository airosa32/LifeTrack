# LifeTrack

> Um app de organização pessoal que une finanças e tarefas em um único lugar — feito em Flutter como projeto de aprendizado.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-state%20management-4CAF50?style=for-the-badge)
![License](https://img.shields.io/badge/license-open%20source-lightgrey?style=for-the-badge)

---

## Sobre o projeto

O **LifeTrack** nasceu de um problema bem real: a dificuldade de acompanhar minhas próprias finanças e tarefas do dia a dia sem precisar abrir três apps diferentes.

Foi também meu **primeiro projeto em Flutter/Dart**, criado para testar na prática o que eu vinha estudando — uma forma de sair da teoria e aprender construindo algo útil de verdade.

## Funcionalidades

- **Dashboard diário** — resumo de receitas, despesas, saldo e tarefas do dia em um só lugar
- **Controle financeiro** — lançamentos de entrada e saída, categorizados e com métodos de pagamento
- **Transações recorrentes** — repetição automática de lançamentos (diária, semanal ou mensal)
- **Alertas financeiros inteligentes** — saldo mínimo, limite de gasto mensal/diário, limite por categoria e percentual de saldo utilizado, com níveis de normal/atenção/crítico
- **Gestão de tarefas** — prioridades, categorias e progresso diário
- **Categorias personalizáveis** — ícones vetoriais e cores próprias para cada categoria
- **Temas claro/escuro** com paleta customizável

## Arquitetura

O projeto segue uma separação clara de responsabilidades, pensando em manter as regras de negócio testáveis e independentes de UI:

```
lib/
├── core/            # constantes, tema, rotas
├── models/          # entidades (Transaction, Task, Category, FinancialAlert...)
├── providers/       # gerenciamento de estado com Riverpod
├── repositories/    # acesso e persistência dos dados
├── screens/         # telas do app
├── services/        # regras de negócio puras (FinanceService, AlertService...)
├── widgets/         # componentes de UI reutilizáveis
└── main.dart        # ponto de entrada do app
```

Os `services` não dependem de Riverpod nem de widgets — recebem os dados já carregados e devolvem resultados prontos para exibição, o que facilita testes unitários e evolução do código.

## Tecnologias

- Flutter & Dart
- Riverpod — gerenciamento de estado
- go_router — navegação
- shared_preferences — persistência local
- intl — internacionalização (pt_BR)

## Próximos passos

- [ ] Migrar persistência para Firebase
- [ ] Publicar na Google Play Store
- [ ] Testes com usuários reais para validar UX e regras de alertas

## Contribuindo

Este é um projeto open source e de aprendizado — sinta-se à vontade para clonar, rodar localmente, sugerir melhorias ou abrir uma PR.

```bash
git clone <url-do-repositorio>
cd lifetrack
flutter pub get
flutter run
```

## Licença

Projeto open source, disponível para estudo e uso livre.

---

<p align="center">Feito enquanto aprendia Flutter</p>