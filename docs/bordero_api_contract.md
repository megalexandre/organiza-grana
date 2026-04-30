# Contrato de API — Cálculo de Borderô

## Endpoint

```
POST /api/bordero/calculate
Authorization: Bearer <access_token>
Content-Type: application/json
```

---

## Request

```json
{
  "change_date": "2026-05-02",
  "monthly_rate_percent": 2.5,
  "receivables": [
    {
      "amount_cents": 150000,
      "due_date": "2026-06-15",
      "awaiting_days": 3
    },
    {
      "amount_cents": 80000,
      "due_date": "2026-07-01",
      "awaiting_days": 3
    }
  ]
}
```

| Campo                | Tipo            | Descrição                                                                 |
|----------------------|-----------------|---------------------------------------------------------------------------|
| `change_date`        | string (date)   | Data base da troca (formato `YYYY-MM-DD`)                                 |
| `monthly_rate_percent` | number        | Taxa de juros ao mês em percentual (ex: `2.5` = 2,5%)                    |
| `receivables`        | array           | Lista de recebíveis a descontar                                           |
| `receivables[].amount_cents` | integer | Valor bruto do título em centavos                                   |
| `receivables[].due_date`     | string (date) | Vencimento do título (`YYYY-MM-DD`)                               |
| `receivables[].awaiting_days` | integer  | Dias de espera após a troca antes de contar os juros                 |

---

## Response — 200 OK

```json
{
  "total_amount_cents": 230000,
  "average_days": 42.5,
  "items": [
    {
      "amount_cents": 150000,
      "due_date": "2026-06-15",
      "total_days": 38,
      "interest_rate_percent": 3.0812,
      "interest_amount_cents": 4621,
      "proceeds_cents": 145379
    },
    {
      "amount_cents": 80000,
      "due_date": "2026-07-01",
      "total_days": 54,
      "interest_rate_percent": 4.3701,
      "interest_amount_cents": 3496,
      "proceeds_cents": 76504
    }
  ]
}
```

| Campo                        | Tipo          | Descrição                                                                 |
|------------------------------|---------------|---------------------------------------------------------------------------|
| `total_amount_cents`         | integer       | Soma do valor bruto de todos os títulos em centavos                       |
| `average_days`               | number        | Prazo médio ponderado em dias                                             |
| `items`                      | array         | Um item de resultado por recebível, na mesma ordem do request             |
| `items[].amount_cents`       | integer       | Valor bruto do título em centavos (espelho do input)                      |
| `items[].due_date`           | string (date) | Vencimento do título (`YYYY-MM-DD`)                                       |
| `items[].total_days`         | integer       | Dias totais de desconto (vencimento − change_date − awaiting_days)        |
| `items[].interest_rate_percent` | number     | Taxa de juros efetiva aplicada ao período, em percentual                  |
| `items[].interest_amount_cents` | integer    | Valor do desconto de juros em centavos                                    |
| `items[].proceeds_cents`   | integer       | Valor líquido a receber em centavos (`amount_cents − interest_amount_cents`) |

---

## Erros

| HTTP | Significado                                      |
|------|--------------------------------------------------|
| 400  | Dados de entrada inválidos (datas, taxa negativa, lista vazia) |
| 401  | Token ausente ou expirado                        |
| 500  | Erro interno do servidor                         |
