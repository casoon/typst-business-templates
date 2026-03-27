use serde::{Deserialize, Serialize};

/// Company/sender data matching data/company.json schema
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CompanyData {
    pub name: String,
    #[serde(default = "default_language")]
    pub language: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub logo: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub logo_width: Option<String>,
    #[serde(default)]
    pub branding: CompanyBranding,
    pub address: CompanyAddress,
    pub contact: CompanyContact,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub tax_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub vat_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub business_owner: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bank_account: Option<BankAccount>,
}

fn default_language() -> String {
    "de".to_string()
}

#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct CompanyBranding {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub accent_color: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub primary_color: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub font_preset: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CompanyAddress {
    pub street: String,
    pub house_number: String,
    pub postal_code: String,
    pub city: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub country: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CompanyContact {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub phone: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub email: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub website: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BankAccount {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bank_name: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub account_holder: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub iban: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bic: Option<String>,
}

/// Top-level invoice document matching templates/invoice/default.typ
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvoiceData {
    pub metadata: InvoiceMetadata,
    pub recipient: InvoiceRecipient,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub salutation: Option<InvoiceSalutation>,
    pub items: Vec<InvoiceItem>,
    pub totals: InvoiceTotals,
    pub payment: InvoicePayment,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub closing: Option<InvoiceClosing>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvoiceMetadata {
    pub invoice_number: String,
    pub invoice_date: String,
    pub due_date: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub customer_number: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub performance_period: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub project_reference: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub show_footer: Option<bool>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvoiceRecipient {
    pub name: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub company: Option<String>,
    pub address: RecipientAddress,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RecipientAddress {
    pub street: String,
    pub house_number: String,
    pub postal_code: String,
    pub city: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub country: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvoiceSalutation {
    pub greeting: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub introduction: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvoiceItem {
    pub position: u32,
    pub description: String,
    pub quantity: f64,
    pub unit: String,
    pub vat_rate: VatRate,
    pub unit_price: MoneyAmount,
    pub total: MoneyAmount,
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub sub_items: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VatRate {
    pub percentage: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MoneyAmount {
    pub amount: f64,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub currency: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvoiceTotals {
    pub subtotal: MoneyAmount,
    pub vat_breakdown: Vec<VatBreakdownItem>,
    pub total: MoneyAmount,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VatBreakdownItem {
    pub rate: u32,
    pub base: MoneyAmount,
    pub amount: MoneyAmount,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvoicePayment {
    pub due_date: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub bank_transfer_note: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvoiceClosing {
    #[serde(skip_serializing_if = "Option::is_none")]
    pub text: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub signature: Option<String>,
}
