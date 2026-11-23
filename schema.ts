import {
  decimal,
  index,
  int,
  mysqlEnum,
  mysqlTable,
  text,
  timestamp,
  uniqueIndex,
  varchar,
} from "drizzle-orm/mysql-core";

/** Usuários autenticados pelo fluxo de OAuth do projeto. */
export const users = mysqlTable("users", {
  id: int("id").autoincrement().primaryKey(),
  openId: varchar("openId", { length: 64 }).notNull().unique(),
  name: text("name"),
  email: varchar("email", { length: 320 }),
  loginMethod: varchar("loginMethod", { length: 64 }),
  role: mysqlEnum("role", ["user", "admin"]).default("user").notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
  lastSignedIn: timestamp("lastSignedIn").defaultNow().notNull(),
});

/** Credencial local e exclusiva para o acesso do proprietário ao cockpit. */
export const ownerCredentials = mysqlTable(
  "ownerCredentials",
  {
    id: int("id").autoincrement().primaryKey(),
    userId: int("userId")
      .notNull()
      .references(() => users.id),
    email: varchar("email", { length: 320 }).notNull().unique(),
    passwordHash: varchar("passwordHash", { length: 512 }).notNull(),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
    updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
  },
  table => [uniqueIndex("owner_credentials_user_unique").on(table.userId)]
);

/** Dados institucionais que apenas o proprietário pode alterar. */
export const ownerProfiles = mysqlTable(
  "ownerProfiles",
  {
    id: int("id").autoincrement().primaryKey(),
    ownerUserId: int("ownerUserId").notNull(),
    ownerName: varchar("ownerName", { length: 160 }),
    businessName: varchar("businessName", { length: 160 }).notNull(),
    businessPhone: text("businessPhone"),
    businessAddress: text("businessAddress"),
    businessPixKey: text("businessPixKey"),
    reminderScheduleTaskUid: varchar("reminderScheduleTaskUid", { length: 65 }),
    dailyDigestScheduleTaskUid: varchar("dailyDigestScheduleTaskUid", {
      length: 65,
    }),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
    updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
  },
  table => [
    uniqueIndex("owner_profiles_owner_unique").on(table.ownerUserId),
    index("owner_profiles_reminder_task").on(table.reminderScheduleTaskUid),
    index("owner_profiles_daily_digest_task").on(
      table.dailyDigestScheduleTaskUid
    ),
  ]
);

/** Cadastro privado de profissionais colaboradores. */
export const barbers = mysqlTable("barbers", {
  id: int("id").autoincrement().primaryKey(),
  fullName: varchar("fullName", { length: 160 }).notNull(),
  email: varchar("email", { length: 320 }),
  accessEmail: varchar("accessEmail", { length: 320 }).unique(),
  phone: text("phone").notNull(),
  document: text("document"),
  emergencyContact: text("emergencyContact"),
  pixKey: text("pixKey"),
  photoUrl: text("photoUrl"),
  serviceCommissionBase: int("serviceCommissionBase").default(45).notNull(),
  active: int("active").default(1).notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
});

/** Histórico privado do Robô, incluindo os resumos automáticos diários. */
export const rodoMessages = mysqlTable(
  "rodoMessages",
  {
    id: int("id").autoincrement().primaryKey(),
    ownerUserId: int("ownerUserId")
      .notNull()
      .references(() => users.id),
    role: mysqlEnum("role", ["user", "assistant"]).notNull(),
    content: text("content").notNull(),
    source: mysqlEnum("source", ["chat", "daily_digest"])
      .default("chat")
      .notNull(),
    dedupeKey: varchar("dedupeKey", { length: 96 }),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
  },
  table => [
    index("rodo_messages_owner_created").on(
      table.ownerUserId,
      table.createdAt
    ),
    uniqueIndex("rodo_messages_owner_dedupe").on(
      table.ownerUserId,
      table.dedupeKey
    ),
  ]
);

/** Atendentes autorizados a operar a agenda de toda a equipe. */
/** Horários fixos configurados pelo proprietário para cada barbeiro. */
export const barberScheduleSlots = mysqlTable(
  "barberScheduleSlots",
  {
    id: int("id").autoincrement().primaryKey(),
    barberId: int("barberId")
      .notNull()
      .references(() => barbers.id),
    weekday: int("weekday").notNull(),
    slotTime: varchar("slotTime", { length: 5 }).notNull(),
    scope: mysqlEnum("scope", ["public", "operational"])
      .default("public")
      .notNull(),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
    updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
  },
  table => [
    uniqueIndex("barber_schedule_slot_unique").on(
      table.barberId,
      table.weekday,
      table.slotTime,
      table.scope
    ),
    index("barber_schedule_barber_weekday").on(table.barberId, table.weekday),
  ]
);

/** Bloqueios manuais de agenda definidos pelo proprietário. */
export const barberScheduleLocks = mysqlTable(
  "barberScheduleLocks",
  {
    id: int("id").autoincrement().primaryKey(),
    barberId: int("barberId")
      .notNull()
      .references(() => barbers.id),
    lockedDate: varchar("lockedDate", { length: 10 }).notNull(),
    startTime: varchar("startTime", { length: 5 }).notNull(),
    endTime: varchar("endTime", { length: 5 }).notNull(),
    reason: varchar("reason", { length: 180 }),
    createdByUserId: int("createdByUserId")
      .notNull()
      .references(() => users.id),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
  },
  table => [
    index("barber_schedule_locks_date").on(table.barberId, table.lockedDate),
    uniqueIndex("barber_schedule_lock_unique").on(
      table.barberId,
      table.lockedDate,
      table.startTime,
      table.endTime
    ),
  ]
);

export const attendants = mysqlTable("attendants", {
  id: int("id").autoincrement().primaryKey(),
  fullName: varchar("fullName", { length: 160 }).notNull(),
  email: varchar("email", { length: 320 }),
  phone: text("phone"),
  document: text("document"),
  photoUrl: text("photoUrl"),
  active: int("active").default(1).notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
});

export const attendantCredentials = mysqlTable(
  "attendantCredentials",
  {
    id: int("id").autoincrement().primaryKey(),
    attendantId: int("attendantId")
      .notNull()
      .references(() => attendants.id),
    userId: int("userId")
      .notNull()
      .references(() => users.id),
    email: varchar("email", { length: 320 }).notNull().unique(),
    passwordHash: varchar("passwordHash", { length: 512 }).notNull(),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
    updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
  },
  table => [
    uniqueIndex("attendant_credentials_attendant_unique").on(table.attendantId),
    uniqueIndex("attendant_credentials_user_unique").on(table.userId),
  ]
);

/** Credenciais locais individuais de acesso dos barbeiros. */
export const barberCredentials = mysqlTable(
  "barberCredentials",
  {
    id: int("id").autoincrement().primaryKey(),
    barberId: int("barberId")
      .notNull()
      .references(() => barbers.id),
    userId: int("userId")
      .notNull()
      .references(() => users.id),
    email: varchar("email", { length: 320 }).notNull().unique(),
    passwordHash: varchar("passwordHash", { length: 512 }).notNull(),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
    updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
  },
  table => [
    uniqueIndex("barber_credentials_barber_unique").on(table.barberId),
    uniqueIndex("barber_credentials_user_unique").on(table.userId),
  ]
);

/** Tokens temporários para recuperação de senha por e-mail. */
export const passwordResetTokens = mysqlTable(
  "passwordResetTokens",
  {
    id: int("id").autoincrement().primaryKey(),
    userId: int("userId")
      .notNull()
      .references(() => users.id),
    accountType: mysqlEnum("accountType", [
      "owner",
      "barber",
      "attendant",
      "customer",
    ]).notNull(),
    credentialId: int("credentialId").notNull(),
    tokenHash: varchar("tokenHash", { length: 64 }).notNull().unique(),
    expiresAt: timestamp("expiresAt").notNull(),
    usedAt: timestamp("usedAt"),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
  },
  table => [
    index("password_reset_lookup").on(
      table.userId,
      table.accountType,
      table.credentialId
    ),
    index("password_reset_expiry").on(table.expiresAt),
  ]
);

/** Conteúdo público editável exclusivamente pelo proprietário. */
export const siteContents = mysqlTable("siteContents", {
  id: int("id").autoincrement().primaryKey(),
  ownerUserId: int("ownerUserId").notNull().unique(),
  logoImageUrl: text("logoImageUrl"),
  heroImageUrl: text("heroImageUrl"),
  studioImageUrl: text("studioImageUrl"),
  finishImageUrl: text("finishImageUrl"),
  detailOneImageUrl: text("detailOneImageUrl"),
  detailTwoImageUrl: text("detailTwoImageUrl"),
  detailThreeImageUrl: text("detailThreeImageUrl"),
  detailFourImageUrl: text("detailFourImageUrl"),
  protocolOneName: varchar("protocolOneName", { length: 160 }),
  protocolOneDescription: text("protocolOneDescription"),
  protocolTwoName: varchar("protocolTwoName", { length: 160 }),
  protocolTwoDescription: text("protocolTwoDescription"),
  protocolThreeName: varchar("protocolThreeName", { length: 160 }),
  protocolThreeDescription: text("protocolThreeDescription"),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
});

/** Regras configuráveis de comissão por percentual de meta individual atingida. */
export const commissionRules = mysqlTable("commissionRules", {
  id: int("id").autoincrement().primaryKey(),
  name: varchar("name", { length: 120 }).notNull(),
  minimumGrossRevenue: decimal("minimumGrossRevenue", {
    precision: 12,
    scale: 2,
  }).notNull(),
  minimumTargetPercent: int("minimumTargetPercent").default(0).notNull(),
  ratePercent: int("ratePercent").notNull(),
  active: int("active").default(1).notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
});

/** Metas individuais de faturamento bruto por colaborador e competência. */
export const individualTargets = mysqlTable(
  "individualTargets",
  {
    id: int("id").autoincrement().primaryKey(),
    barberId: int("barberId")
      .notNull()
      .references(() => barbers.id),
    title: varchar("title", { length: 160 }).notNull(),
    referenceMonth: varchar("referenceMonth", { length: 7 }).notNull(),
    grossRevenueTarget: decimal("grossRevenueTarget", {
      precision: 12,
      scale: 2,
    }).notNull(),
    notes: text("notes"),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
    updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
  },
  table => [
    index("targets_barber_month").on(table.barberId, table.referenceMonth),
  ]
);

/** Tipos de serviço cadastrados pelo proprietário. */
export const serviceCategories = mysqlTable("serviceCategories", {
  id: int("id").autoincrement().primaryKey(),
  name: varchar("name", { length: 120 }).notNull(),
  description: text("description"),
  active: int("active").default(1).notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
});

export const services = mysqlTable("services", {
  id: int("id").autoincrement().primaryKey(),
  categoryId: int("categoryId").references(() => serviceCategories.id),
  name: varchar("name", { length: 160 }).notNull(),
  price: decimal("price", { precision: 12, scale: 2 }).notNull(),
  durationMinutes: int("durationMinutes"),
  active: int("active").default(1).notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
});

/** Catálogo de produtos para venda ou uso operacional. */
export const products = mysqlTable("products", {
  id: int("id").autoincrement().primaryKey(),
  name: varchar("name", { length: 160 }).notNull(),
  category: varchar("category", { length: 120 }),
  purchasePrice: decimal("purchasePrice", { precision: 12, scale: 2 }),
  salePrice: decimal("salePrice", { precision: 12, scale: 2 }),
  stockQuantity: int("stockQuantity").default(0).notNull(),
  active: int("active").default(1).notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
});

/** Itens consumidos no atendimento e operação. */
export const consumptionItems = mysqlTable("consumptionItems", {
  id: int("id").autoincrement().primaryKey(),
  name: varchar("name", { length: 160 }).notNull(),
  unit: varchar("unit", { length: 48 }).notNull(),
  unitPrice: decimal("unitPrice", { precision: 12, scale: 2 }),
  currentStock: decimal("currentStock", { precision: 12, scale: 2 })
    .default("0")
    .notNull(),
  minimumStock: decimal("minimumStock", { precision: 12, scale: 2 })
    .default("0")
    .notNull(),
  active: int("active").default(1).notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
});

/** Materiais de limpeza administrados exclusivamente pelo proprietário. */
export const cleaningSupplies = mysqlTable("cleaningSupplies", {
  id: int("id").autoincrement().primaryKey(),
  name: varchar("name", { length: 160 }).notNull(),
  unit: varchar("unit", { length: 48 }).notNull(),
  currentStock: decimal("currentStock", { precision: 12, scale: 2 })
    .default("0")
    .notNull(),
  minimumStock: decimal("minimumStock", { precision: 12, scale: 2 })
    .default("0")
    .notNull(),
  active: int("active").default(1).notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
});

/** Auditoria das reposições e baixas manuais de materiais de limpeza. */
export const cleaningSupplyMovements = mysqlTable(
  "cleaningSupplyMovements",
  {
    id: int("id").autoincrement().primaryKey(),
    cleaningSupplyId: int("cleaningSupplyId")
      .notNull()
      .references(() => cleaningSupplies.id),
    movementType: mysqlEnum("movementType", ["in", "out"]).notNull(),
    quantity: decimal("quantity", { precision: 12, scale: 2 }).notNull(),
    balanceAfter: decimal("balanceAfter", {
      precision: 12,
      scale: 2,
    }).notNull(),
    notes: text("notes"),
    occurredAt: timestamp("occurredAt").defaultNow().notNull(),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
  },
  table => [
    index("cleaning_supply_movements_supply_date").on(
      table.cleaningSupplyId,
      table.occurredAt
    ),
  ]
);

/** Vendas de produtos registradas por barbeiro. */
export const productSales = mysqlTable(
  "productSales",
  {
    id: int("id").autoincrement().primaryKey(),
    barberId: int("barberId")
      .notNull()
      .references(() => barbers.id),
    productId: int("productId")
      .notNull()
      .references(() => products.id),
    quantity: int("quantity").notNull(),
    amount: decimal("amount", { precision: 12, scale: 2 }).notNull(),
    occurredAt: timestamp("occurredAt").defaultNow().notNull(),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
  },
  table => [
    index("product_sales_barber_date").on(table.barberId, table.occurredAt),
  ]
);

/** Vendas de itens de consumo lançadas pela operação de atendimento, separadas do faturamento do barbeiro. */
export const consumptionSales = mysqlTable(
  "consumptionSales",
  {
    id: int("id").autoincrement().primaryKey(),
    attendantId: int("attendantId").references(() => attendants.id),
    barberId: int("barberId").references(() => barbers.id),
    consumptionItemId: int("consumptionItemId")
      .notNull()
      .references(() => consumptionItems.id),
    quantity: int("quantity").notNull(),
    amount: decimal("amount", { precision: 12, scale: 2 }).notNull(),
    occurredAt: timestamp("occurredAt").defaultNow().notNull(),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
  },
  table => [
    index("consumption_sales_attendant_date").on(
      table.attendantId,
      table.occurredAt
    ),
  ]
);

/** Lançamentos para o fechamento de caixa. */
export const cashEntries = mysqlTable(
  "cashEntries",
  {
    id: int("id").autoincrement().primaryKey(),
    entryType: mysqlEnum("entryType", ["income", "expense"]).notNull(),
    amount: decimal("amount", { precision: 12, scale: 2 }).notNull(),
    source: varchar("source", { length: 160 }).notNull(),
    category: varchar("category", { length: 120 }),
    barberId: int("barberId").references(() => barbers.id),
    serviceId: int("serviceId").references(() => services.id),
    appointmentId: int("appointmentId").references(() => appointments.id),
    paymentMethodId: int("paymentMethodId").references(() => paymentMethods.id),
    productSaleId: int("productSaleId").references(() => productSales.id),
    consumptionSaleId: int("consumptionSaleId").references(
      () => consumptionSales.id
    ),
    notes: text("notes"),
    occurredAt: timestamp("occurredAt").defaultNow().notNull(),
    voidedAt: timestamp("voidedAt"),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
  },
  table => [index("cash_entries_date").on(table.occurredAt)]
);

/** Formas de pagamento ativadas pelo proprietário. */
export const paymentMethods = mysqlTable("paymentMethods", {
  id: int("id").autoincrement().primaryKey(),
  name: varchar("name", { length: 120 }).notNull(),
  kind: mysqlEnum("kind", ["cash", "pix", "card", "online", "other"]).notNull(),
  active: int("active").default(1).notNull(),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
});

/** Clientes e seus identificadores protegidos para agenda e relacionamento. */
export const clients = mysqlTable("clients", {
  id: int("id").autoincrement().primaryKey(),
  fullName: varchar("fullName", { length: 160 }).notNull(),
  email: text("email"),
  phone: text("phone").notNull(),
  phoneHash: varchar("phoneHash", { length: 64 }).notNull().unique(),
  document: text("document"),
  photoUrl: text("photoUrl"),
  archivedAt: timestamp("archivedAt"),
  createdAt: timestamp("createdAt").defaultNow().notNull(),
  updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
});

/** Credenciais locais para o acesso autenticado do cliente. */
export const clientCredentials = mysqlTable(
  "clientCredentials",
  {
    id: int("id").autoincrement().primaryKey(),
    clientId: int("clientId")
      .notNull()
      .references(() => clients.id),
    userId: int("userId")
      .notNull()
      .references(() => users.id),
    email: varchar("email", { length: 320 }).notNull().unique(),
    passwordHash: varchar("passwordHash", { length: 512 }).notNull(),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
    updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
  },
  table => [
    uniqueIndex("client_credentials_client_unique").on(table.clientId),
    uniqueIndex("client_credentials_user_unique").on(table.userId),
  ]
);

/** Solicitações de assinatura pagas via Pix, aguardando conferência manual do proprietário. */
export const customerSubscriptions = mysqlTable(
  "customerSubscriptions",
  {
    id: int("id").autoincrement().primaryKey(),
    clientId: int("clientId")
      .notNull()
      .references(() => clients.id),
    planCategory: varchar("planCategory", { length: 160 }).notNull(),
    planName: varchar("planName", { length: 64 }).notNull(),
    visitsPerMonth: int("visitsPerMonth").notNull(),
    fullValue: decimal("fullValue", { precision: 12, scale: 2 }).notNull(),
    discountPercent: int("discountPercent").notNull(),
    planValue: decimal("planValue", { precision: 12, scale: 2 }).notNull(),
    unitValue: decimal("unitValue", { precision: 12, scale: 2 }).notNull(),
    paymentMethod: mysqlEnum("paymentMethod", ["pix"]).default("pix").notNull(),
    status: mysqlEnum("status", [
      "pending",
      "confirmed",
      "rejected",
      "cancelled",
    ])
      .default("pending")
      .notNull(),
    customerNote: text("customerNote"),
    proofStorageKey: text("proofStorageKey"),
    proofOriginalName: varchar("proofOriginalName", { length: 180 }),
    proofMimeType: varchar("proofMimeType", { length: 80 }),
    proofFileSize: int("proofFileSize"),
    proofUploadedAt: timestamp("proofUploadedAt"),
    paymentReportedAt: timestamp("paymentReportedAt"),
    confirmedAt: timestamp("confirmedAt"),
    confirmedByUserId: int("confirmedByUserId").references(() => users.id),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
    updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
  },
  table => [
    index("customer_subscriptions_client_created").on(
      table.clientId,
      table.createdAt
    ),
    index("customer_subscriptions_status_created").on(
      table.status,
      table.createdAt
    ),
  ]
);

/** Agendamentos com vínculo a serviço e opção de pagamento. */
export const appointments = mysqlTable(
  "appointments",
  {
    id: int("id").autoincrement().primaryKey(),
    clientId: int("clientId")
      .notNull()
      .references(() => clients.id),
    barberId: int("barberId")
      .notNull()
      .references(() => barbers.id),
    serviceId: int("serviceId")
      .notNull()
      .references(() => services.id),
    paymentChoice: mysqlEnum("paymentChoice", ["on_site", "prepaid"]).notNull(),
    /** Preferência informada pelo cliente para o fechamento presencial. */
    paymentPreference: varchar("paymentPreference", { length: 20 }),
    paymentMethodId: int("paymentMethodId").references(() => paymentMethods.id),
    status: mysqlEnum("status", [
      "requested",
      "confirmed",
      "paid",
      "completed",
      "cancelled",
      "no_show",
    ])
      .default("requested")
      .notNull(),
    bookingSource: mysqlEnum("bookingSource", [
      "client",
      "barber",
      "owner",
      "attendant",
    ])
      .default("client")
      .notNull(),
    overlapMode: mysqlEnum("overlapMode", ["standard", "team_overlap"])
      .default("standard")
      .notNull(),
    scheduledAt: timestamp("scheduledAt").notNull(),
    internalReferenceCode: varchar("internalReferenceCode", {
      length: 64,
    }).unique(),
    scheduledEndAt: timestamp("scheduledEndAt"),
    serviceDurationMinutes: int("serviceDurationMinutes"),
    notes: text("notes"),
    completionNotes: text("completionNotes"),
    discountPercent: int("discountPercent").default(0).notNull(),
    discountAmount: decimal("discountAmount", {
      precision: 12,
      scale: 2,
    })
      .default("0.00")
      .notNull(),
    cancelledAt: timestamp("cancelledAt"),
    completedAt: timestamp("completedAt"),
    stripeCheckoutSessionId: varchar("stripeCheckoutSessionId", {
      length: 255,
    }),
    reminderSentAt: timestamp("reminderSentAt"),
    reminder24SentAt: timestamp("reminder24SentAt"),
    reminder2SentAt: timestamp("reminder2SentAt"),
    reminderError: text("reminderError"),
    archivedAt: timestamp("archivedAt"),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
    updatedAt: timestamp("updatedAt").defaultNow().onUpdateNow().notNull(),
  },
  table => [
    index("appointments_barber_date").on(table.barberId, table.scheduledAt),
    index("appointments_barber_end").on(table.barberId, table.scheduledEndAt),
    index("appointments_client_date").on(table.clientId, table.scheduledAt),
  ]
);

/** Avisos internos exibidos ao cliente na própria Área do Cliente. */
export const customerNotifications = mysqlTable(
  "customerNotifications",
  {
    id: int("id").autoincrement().primaryKey(),
    clientId: int("clientId").notNull().references(() => clients.id),
    appointmentId: int("appointmentId").references(() => appointments.id),
    kind: mysqlEnum("kind", ["reminder_24", "reminder_2", "change", "cancel"]).notNull(),
    title: varchar("title", { length: 180 }).notNull(),
    body: text("body").notNull(),
    readAt: timestamp("readAt"),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
  },
  table => [
    index("customer_notifications_client_created").on(table.clientId, table.createdAt),
  ]
);

/** Registro imutável das ações operacionais relevantes para o proprietário. */
export const auditEvents = mysqlTable(
  "auditEvents",
  {
    id: int("id").autoincrement().primaryKey(),
    actorUserId: int("actorUserId").references(() => users.id),
    action: varchar("action", { length: 80 }).notNull(),
    entityType: varchar("entityType", { length: 80 }).notNull(),
    entityId: int("entityId"),
    summary: varchar("summary", { length: 500 }).notNull(),
    metadata: text("metadata"),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
  },
  table => [
    index("audit_events_created").on(table.createdAt),
    index("audit_events_entity").on(table.entityType, table.entityId),
  ]
);

/** Serviços selecionados em cada reserva, preservando preço e duração no momento do agendamento. */
export const appointmentServices = mysqlTable(
  "appointmentServices",
  {
    id: int("id").autoincrement().primaryKey(),
    appointmentId: int("appointmentId")
      .notNull()
      .references(() => appointments.id),
    serviceId: int("serviceId")
      .notNull()
      .references(() => services.id),
    servicePrice: decimal("servicePrice", {
      precision: 12,
      scale: 2,
    }).notNull(),
    durationMinutes: int("durationMinutes").notNull(),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
  },
  table => [
    uniqueIndex("appointment_services_unique").on(
      table.appointmentId,
      table.serviceId
    ),
    index("appointment_services_appointment").on(table.appointmentId),
  ]
);

/** Produtos vendidos dentro de um atendimento fechado, com preço congelado no momento da venda. */
export const appointmentProducts = mysqlTable(
  "appointmentProducts",
  {
    id: int("id").autoincrement().primaryKey(),
    appointmentId: int("appointmentId")
      .notNull()
      .references(() => appointments.id),
    productId: int("productId")
      .notNull()
      .references(() => products.id),
    productName: varchar("productName", { length: 160 }).notNull(),
    unitPrice: decimal("unitPrice", { precision: 12, scale: 2 }).notNull(),
    quantity: int("quantity").notNull(),
    amount: decimal("amount", { precision: 12, scale: 2 }).notNull(),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
  },
  table => [index("appointment_products_appointment").on(table.appointmentId)]
);

/** Itens de consumo vendidos dentro de um atendimento fechado, com baixa automática de estoque. */
export const appointmentConsumptionItems = mysqlTable(
  "appointmentConsumptionItems",
  {
    id: int("id").autoincrement().primaryKey(),
    appointmentId: int("appointmentId")
      .notNull()
      .references(() => appointments.id),
    consumptionItemId: int("consumptionItemId")
      .notNull()
      .references(() => consumptionItems.id),
    itemName: varchar("itemName", { length: 160 }).notNull(),
    unitPrice: decimal("unitPrice", { precision: 12, scale: 2 }).notNull(),
    quantity: int("quantity").notNull(),
    amount: decimal("amount", { precision: 12, scale: 2 }).notNull(),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
  },
  table => [
    index("appointment_consumption_appointment").on(table.appointmentId),
  ]
);

/** Relatos privados de experiência vinculados a um atendimento concluído. */
export const clientFeedbacks = mysqlTable(
  "clientFeedbacks",
  {
    id: int("id").autoincrement().primaryKey(),
    clientId: int("clientId")
      .notNull()
      .references(() => clients.id),
    appointmentId: int("appointmentId")
      .notNull()
      .references(() => appointments.id),
    message: text("message").notNull(),
    createdAt: timestamp("createdAt").defaultNow().notNull(),
  },
  table => [
    uniqueIndex("client_feedbacks_appointment_unique").on(table.appointmentId),
    index("client_feedbacks_client_created").on(
      table.clientId,
      table.createdAt
    ),
  ]
);

export type User = typeof users.$inferSelect;
export type InsertUser = typeof users.$inferInsert;
export type InsertOwnerCredential = typeof ownerCredentials.$inferInsert;
export type InsertOwnerProfile = typeof ownerProfiles.$inferInsert;
export type InsertBarber = typeof barbers.$inferInsert;
export type InsertBarberCredential = typeof barberCredentials.$inferInsert;
export type InsertBarberScheduleSlot = typeof barberScheduleSlots.$inferInsert;
export type InsertAttendant = typeof attendants.$inferInsert;
export type InsertAttendantCredential =
  typeof attendantCredentials.$inferInsert;
export type InsertSiteContent = typeof siteContents.$inferInsert;
export type InsertCommissionRule = typeof commissionRules.$inferInsert;
export type InsertIndividualTarget = typeof individualTargets.$inferInsert;
export type InsertServiceCategory = typeof serviceCategories.$inferInsert;
export type InsertService = typeof services.$inferInsert;
export type InsertProduct = typeof products.$inferInsert;
export type InsertProductSale = typeof productSales.$inferInsert;
export type InsertConsumptionItem = typeof consumptionItems.$inferInsert;
export type InsertConsumptionSale = typeof consumptionSales.$inferInsert;
export type InsertCleaningSupply = typeof cleaningSupplies.$inferInsert;
export type InsertCleaningSupplyMovement =
  typeof cleaningSupplyMovements.$inferInsert;
export type InsertCashEntry = typeof cashEntries.$inferInsert;
export type InsertPaymentMethod = typeof paymentMethods.$inferInsert;
export type InsertClientCredential = typeof clientCredentials.$inferInsert;
export type InsertClient = typeof clients.$inferInsert;
export type InsertAppointment = typeof appointments.$inferInsert;
export type InsertAppointmentService = typeof appointmentServices.$inferInsert;
export type InsertAppointmentProduct = typeof appointmentProducts.$inferInsert;
export type InsertAppointmentConsumptionItem =
  typeof appointmentConsumptionItems.$inferInsert;
export type InsertClientFeedback = typeof clientFeedbacks.$inferInsert;
export type InsertCustomerSubscription =
  typeof customerSubscriptions.$inferInsert;
