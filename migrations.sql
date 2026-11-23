CREATE TABLE `barbers` (
	`id` int AUTO_INCREMENT NOT NULL,
	`fullName` varchar(160) NOT NULL,
	`phone` varchar(32) NOT NULL,
	`document` varchar(32),
	`emergencyContact` varchar(255),
	`pixKey` varchar(255),
	`active` int NOT NULL DEFAULT 1,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `barbers_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `cashEntries` (
	`id` int AUTO_INCREMENT NOT NULL,
	`entryType` enum('income','expense') NOT NULL,
	`amount` decimal(12,2) NOT NULL,
	`source` varchar(160) NOT NULL,
	`barberId` int,
	`serviceId` int,
	`notes` text,
	`occurredAt` timestamp NOT NULL DEFAULT (now()),
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `cashEntries_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `commissionRules` (
	`id` int AUTO_INCREMENT NOT NULL,
	`name` varchar(120) NOT NULL,
	`minimumGrossRevenue` decimal(12,2) NOT NULL,
	`ratePercent` int NOT NULL,
	`active` int NOT NULL DEFAULT 1,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `commissionRules_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `consumptionItems` (
	`id` int AUTO_INCREMENT NOT NULL,
	`name` varchar(160) NOT NULL,
	`unit` varchar(48) NOT NULL,
	`currentStock` decimal(12,2) NOT NULL DEFAULT '0',
	`minimumStock` decimal(12,2) NOT NULL DEFAULT '0',
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `consumptionItems_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `individualTargets` (
	`id` int AUTO_INCREMENT NOT NULL,
	`barberId` int NOT NULL,
	`title` varchar(160) NOT NULL,
	`referenceMonth` varchar(7) NOT NULL,
	`grossRevenueTarget` decimal(12,2) NOT NULL,
	`notes` text,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `individualTargets_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `ownerProfiles` (
	`id` int AUTO_INCREMENT NOT NULL,
	`ownerUserId` int NOT NULL,
	`ownerName` varchar(160),
	`businessName` varchar(160) NOT NULL,
	`businessPhone` varchar(32),
	`businessAddress` text,
	`businessPixKey` varchar(255),
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `ownerProfiles_id` PRIMARY KEY(`id`),
	CONSTRAINT `owner_profiles_owner_unique` UNIQUE(`ownerUserId`)
);
--> statement-breakpoint
CREATE TABLE `products` (
	`id` int AUTO_INCREMENT NOT NULL,
	`name` varchar(160) NOT NULL,
	`category` varchar(120),
	`purchasePrice` decimal(12,2),
	`salePrice` decimal(12,2),
	`stockQuantity` int NOT NULL DEFAULT 0,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `products_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `serviceCategories` (
	`id` int AUTO_INCREMENT NOT NULL,
	`name` varchar(120) NOT NULL,
	`description` text,
	`active` int NOT NULL DEFAULT 1,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `serviceCategories_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `services` (
	`id` int AUTO_INCREMENT NOT NULL,
	`categoryId` int,
	`name` varchar(160) NOT NULL,
	`price` decimal(12,2) NOT NULL,
	`durationMinutes` int,
	`active` int NOT NULL DEFAULT 1,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `services_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `users` (
	`id` int AUTO_INCREMENT NOT NULL,
	`openId` varchar(64) NOT NULL,
	`name` text,
	`email` varchar(320),
	`loginMethod` varchar(64),
	`role` enum('user','admin') NOT NULL DEFAULT 'user',
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	`lastSignedIn` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `users_id` PRIMARY KEY(`id`),
	CONSTRAINT `users_openId_unique` UNIQUE(`openId`)
);
--> statement-breakpoint
ALTER TABLE `cashEntries` ADD CONSTRAINT `cashEntries_barberId_barbers_id_fk` FOREIGN KEY (`barberId`) REFERENCES `barbers`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `cashEntries` ADD CONSTRAINT `cashEntries_serviceId_services_id_fk` FOREIGN KEY (`serviceId`) REFERENCES `services`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `individualTargets` ADD CONSTRAINT `individualTargets_barberId_barbers_id_fk` FOREIGN KEY (`barberId`) REFERENCES `barbers`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `services` ADD CONSTRAINT `services_categoryId_serviceCategories_id_fk` FOREIGN KEY (`categoryId`) REFERENCES `serviceCategories`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX `cash_entries_date` ON `cashEntries` (`occurredAt`);--> statement-breakpoint
CREATE INDEX `targets_barber_month` ON `individualTargets` (`barberId`,`referenceMonth`);

ALTER TABLE `commissionRules` ADD `minimumTargetPercent` int DEFAULT 0 NOT NULL;

CREATE TABLE `appointments` (
	`id` int AUTO_INCREMENT NOT NULL,
	`clientId` int NOT NULL,
	`barberId` int NOT NULL,
	`serviceId` int NOT NULL,
	`paymentChoice` enum('on_site','prepaid') NOT NULL,
	`paymentMethodId` int,
	`status` enum('requested','confirmed','paid','cancelled') NOT NULL DEFAULT 'requested',
	`scheduledAt` timestamp NOT NULL,
	`stripeCheckoutSessionId` varchar(255),
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `appointments_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `clients` (
	`id` int AUTO_INCREMENT NOT NULL,
	`fullName` varchar(160) NOT NULL,
	`phone` varchar(255) NOT NULL,
	`phoneHash` varchar(64) NOT NULL,
	`document` varchar(255),
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `clients_id` PRIMARY KEY(`id`),
	CONSTRAINT `clients_phoneHash_unique` UNIQUE(`phoneHash`)
);
--> statement-breakpoint
CREATE TABLE `paymentMethods` (
	`id` int AUTO_INCREMENT NOT NULL,
	`name` varchar(120) NOT NULL,
	`kind` enum('cash','pix','card','online','other') NOT NULL,
	`active` int NOT NULL DEFAULT 1,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `paymentMethods_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
ALTER TABLE `barbers` ADD `accessEmail` varchar(320);--> statement-breakpoint
ALTER TABLE `barbers` ADD CONSTRAINT `barbers_accessEmail_unique` UNIQUE(`accessEmail`);--> statement-breakpoint
ALTER TABLE `appointments` ADD CONSTRAINT `appointments_clientId_clients_id_fk` FOREIGN KEY (`clientId`) REFERENCES `clients`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `appointments` ADD CONSTRAINT `appointments_barberId_barbers_id_fk` FOREIGN KEY (`barberId`) REFERENCES `barbers`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `appointments` ADD CONSTRAINT `appointments_serviceId_services_id_fk` FOREIGN KEY (`serviceId`) REFERENCES `services`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `appointments` ADD CONSTRAINT `appointments_paymentMethodId_paymentMethods_id_fk` FOREIGN KEY (`paymentMethodId`) REFERENCES `paymentMethods`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX `appointments_barber_date` ON `appointments` (`barberId`,`scheduledAt`);--> statement-breakpoint
CREATE INDEX `appointments_client_date` ON `appointments` (`clientId`,`scheduledAt`);

CREATE TABLE `ownerCredentials` (
	`id` int AUTO_INCREMENT NOT NULL,
	`userId` int NOT NULL,
	`email` varchar(320) NOT NULL,
	`passwordHash` varchar(512) NOT NULL,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `ownerCredentials_id` PRIMARY KEY(`id`),
	CONSTRAINT `ownerCredentials_email_unique` UNIQUE(`email`),
	CONSTRAINT `owner_credentials_user_unique` UNIQUE(`userId`)
);
--> statement-breakpoint
ALTER TABLE `ownerCredentials` ADD CONSTRAINT `ownerCredentials_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;

ALTER TABLE `barbers` MODIFY COLUMN `phone` text NOT NULL;--> statement-breakpoint
ALTER TABLE `barbers` MODIFY COLUMN `document` text;--> statement-breakpoint
ALTER TABLE `barbers` MODIFY COLUMN `emergencyContact` text;--> statement-breakpoint
ALTER TABLE `barbers` MODIFY COLUMN `pixKey` text;--> statement-breakpoint
ALTER TABLE `clients` MODIFY COLUMN `phone` text NOT NULL;--> statement-breakpoint
ALTER TABLE `clients` MODIFY COLUMN `document` text;--> statement-breakpoint
ALTER TABLE `ownerProfiles` MODIFY COLUMN `businessPhone` text;--> statement-breakpoint
ALTER TABLE `ownerProfiles` MODIFY COLUMN `businessPixKey` text;

CREATE TABLE `barberCredentials` (
	`id` int AUTO_INCREMENT NOT NULL,
	`barberId` int NOT NULL,
	`userId` int NOT NULL,
	`email` varchar(320) NOT NULL,
	`passwordHash` varchar(512) NOT NULL,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `barberCredentials_id` PRIMARY KEY(`id`),
	CONSTRAINT `barberCredentials_email_unique` UNIQUE(`email`),
	CONSTRAINT `barber_credentials_barber_unique` UNIQUE(`barberId`),
	CONSTRAINT `barber_credentials_user_unique` UNIQUE(`userId`)
);
--> statement-breakpoint
CREATE TABLE `productSales` (
	`id` int AUTO_INCREMENT NOT NULL,
	`barberId` int NOT NULL,
	`productId` int NOT NULL,
	`quantity` int NOT NULL,
	`amount` decimal(12,2) NOT NULL,
	`occurredAt` timestamp NOT NULL DEFAULT (now()),
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `productSales_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `siteContents` (
	`id` int AUTO_INCREMENT NOT NULL,
	`ownerUserId` int NOT NULL,
	`heroImageUrl` text,
	`studioImageUrl` text,
	`finishImageUrl` text,
	`protocolOneName` varchar(160),
	`protocolOneDescription` text,
	`protocolTwoName` varchar(160),
	`protocolTwoDescription` text,
	`protocolThreeName` varchar(160),
	`protocolThreeDescription` text,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `siteContents_id` PRIMARY KEY(`id`),
	CONSTRAINT `siteContents_ownerUserId_unique` UNIQUE(`ownerUserId`)
);
--> statement-breakpoint
ALTER TABLE `barberCredentials` ADD CONSTRAINT `barberCredentials_barberId_barbers_id_fk` FOREIGN KEY (`barberId`) REFERENCES `barbers`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `barberCredentials` ADD CONSTRAINT `barberCredentials_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `productSales` ADD CONSTRAINT `productSales_barberId_barbers_id_fk` FOREIGN KEY (`barberId`) REFERENCES `barbers`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `productSales` ADD CONSTRAINT `productSales_productId_products_id_fk` FOREIGN KEY (`productId`) REFERENCES `products`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX `product_sales_barber_date` ON `productSales` (`barberId`,`occurredAt`);

ALTER TABLE `appointments` MODIFY COLUMN `status` enum('requested','confirmed','paid','completed','cancelled','no_show') NOT NULL DEFAULT 'requested';--> statement-breakpoint
ALTER TABLE `appointments` ADD `bookingSource` enum('client','barber','owner') DEFAULT 'client' NOT NULL;--> statement-breakpoint
ALTER TABLE `appointments` ADD `scheduledEndAt` timestamp;--> statement-breakpoint
ALTER TABLE `appointments` ADD `serviceDurationMinutes` int;--> statement-breakpoint
ALTER TABLE `appointments` ADD `notes` text;--> statement-breakpoint
ALTER TABLE `appointments` ADD `completionNotes` text;--> statement-breakpoint
ALTER TABLE `appointments` ADD `cancelledAt` timestamp;--> statement-breakpoint
ALTER TABLE `appointments` ADD `completedAt` timestamp;--> statement-breakpoint
CREATE INDEX `appointments_barber_end` ON `appointments` (`barberId`,`scheduledEndAt`);

ALTER TABLE `consumptionItems` ADD `unitPrice` decimal(12,2);

CREATE TABLE `attendantCredentials` (
	`id` int AUTO_INCREMENT NOT NULL,
	`attendantId` int NOT NULL,
	`userId` int NOT NULL,
	`email` varchar(320) NOT NULL,
	`passwordHash` varchar(512) NOT NULL,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `attendantCredentials_id` PRIMARY KEY(`id`),
	CONSTRAINT `attendantCredentials_email_unique` UNIQUE(`email`),
	CONSTRAINT `attendant_credentials_attendant_unique` UNIQUE(`attendantId`),
	CONSTRAINT `attendant_credentials_user_unique` UNIQUE(`userId`)
);
--> statement-breakpoint
CREATE TABLE `attendants` (
	`id` int AUTO_INCREMENT NOT NULL,
	`fullName` varchar(160) NOT NULL,
	`active` int NOT NULL DEFAULT 1,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `attendants_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
ALTER TABLE `appointments` MODIFY COLUMN `bookingSource` enum('client','barber','owner','attendant') NOT NULL DEFAULT 'client';--> statement-breakpoint
ALTER TABLE `attendantCredentials` ADD CONSTRAINT `attendantCredentials_attendantId_attendants_id_fk` FOREIGN KEY (`attendantId`) REFERENCES `attendants`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `attendantCredentials` ADD CONSTRAINT `attendantCredentials_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;

ALTER TABLE `attendants` ADD `phone` text;--> statement-breakpoint
ALTER TABLE `attendants` ADD `document` text;


ALTER TABLE `attendants` MODIFY COLUMN `phone` text;

ALTER TABLE `appointments` ADD `reminderSentAt` timestamp;--> statement-breakpoint
ALTER TABLE `appointments` ADD `reminderError` text;--> statement-breakpoint
ALTER TABLE `attendants` ADD `email` varchar(320);--> statement-breakpoint
ALTER TABLE `attendants` ADD `photoUrl` text;--> statement-breakpoint
ALTER TABLE `barbers` ADD `email` varchar(320);--> statement-breakpoint
ALTER TABLE `barbers` ADD `photoUrl` text;--> statement-breakpoint
ALTER TABLE `barbers` ADD `serviceCommissionBase` int DEFAULT 45 NOT NULL;--> statement-breakpoint
ALTER TABLE `clients` ADD `email` text;--> statement-breakpoint
ALTER TABLE `clients` ADD `photoUrl` text;--> statement-breakpoint
ALTER TABLE `siteContents` ADD `detailOneImageUrl` text;--> statement-breakpoint
ALTER TABLE `siteContents` ADD `detailTwoImageUrl` text;--> statement-breakpoint
ALTER TABLE `siteContents` ADD `detailThreeImageUrl` text;--> statement-breakpoint
ALTER TABLE `siteContents` ADD `detailFourImageUrl` text;

ALTER TABLE `ownerProfiles` ADD `reminderScheduleTaskUid` varchar(65);

CREATE INDEX `owner_profiles_reminder_task` ON `ownerProfiles` (`reminderScheduleTaskUid`);

CREATE TABLE `consumptionSales` (
	`id` int AUTO_INCREMENT NOT NULL,
	`attendantId` int NOT NULL,
	`consumptionItemId` int NOT NULL,
	`quantity` int NOT NULL,
	`amount` decimal(12,2) NOT NULL,
	`occurredAt` timestamp NOT NULL DEFAULT (now()),
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `consumptionSales_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
ALTER TABLE `appointments` ADD `archivedAt` timestamp;--> statement-breakpoint
ALTER TABLE `cashEntries` ADD `category` varchar(120);--> statement-breakpoint
ALTER TABLE `cashEntries` ADD `appointmentId` int;--> statement-breakpoint
ALTER TABLE `cashEntries` ADD `productSaleId` int;--> statement-breakpoint
ALTER TABLE `cashEntries` ADD `consumptionSaleId` int;--> statement-breakpoint
ALTER TABLE `cashEntries` ADD `voidedAt` timestamp;--> statement-breakpoint
ALTER TABLE `clients` ADD `archivedAt` timestamp;--> statement-breakpoint
ALTER TABLE `consumptionItems` ADD `active` int DEFAULT 1 NOT NULL;--> statement-breakpoint
ALTER TABLE `products` ADD `active` int DEFAULT 1 NOT NULL;--> statement-breakpoint
ALTER TABLE `consumptionSales` ADD CONSTRAINT `consumptionSales_attendantId_attendants_id_fk` FOREIGN KEY (`attendantId`) REFERENCES `attendants`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `consumptionSales` ADD CONSTRAINT `consumptionSales_consumptionItemId_consumptionItems_id_fk` FOREIGN KEY (`consumptionItemId`) REFERENCES `consumptionItems`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX `consumption_sales_attendant_date` ON `consumptionSales` (`attendantId`,`occurredAt`);--> statement-breakpoint
ALTER TABLE `cashEntries` ADD CONSTRAINT `cashEntries_appointmentId_appointments_id_fk` FOREIGN KEY (`appointmentId`) REFERENCES `appointments`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `cashEntries` ADD CONSTRAINT `cashEntries_productSaleId_productSales_id_fk` FOREIGN KEY (`productSaleId`) REFERENCES `productSales`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `cashEntries` ADD CONSTRAINT `cashEntries_consumptionSaleId_consumptionSales_id_fk` FOREIGN KEY (`consumptionSaleId`) REFERENCES `consumptionSales`(`id`) ON DELETE no action ON UPDATE no action;

CREATE TABLE `cleaningSupplies` (
	`id` int AUTO_INCREMENT NOT NULL,
	`name` varchar(160) NOT NULL,
	`unit` varchar(48) NOT NULL,
	`currentStock` decimal(12,2) NOT NULL DEFAULT '0',
	`minimumStock` decimal(12,2) NOT NULL DEFAULT '0',
	`active` int NOT NULL DEFAULT 1,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `cleaningSupplies_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `cleaningSupplyMovements` (
	`id` int AUTO_INCREMENT NOT NULL,
	`cleaningSupplyId` int NOT NULL,
	`movementType` enum('in','out') NOT NULL,
	`quantity` decimal(12,2) NOT NULL,
	`balanceAfter` decimal(12,2) NOT NULL,
	`notes` text,
	`occurredAt` timestamp NOT NULL DEFAULT (now()),
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `cleaningSupplyMovements_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
ALTER TABLE `cleaningSupplyMovements` ADD CONSTRAINT `cleaningSupplyMovements_cleaningSupplyId_cleaningSupplies_id_fk` FOREIGN KEY (`cleaningSupplyId`) REFERENCES `cleaningSupplies`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX `cleaning_supply_movements_supply_date` ON `cleaningSupplyMovements` (`cleaningSupplyId`,`occurredAt`);

ALTER TABLE `siteContents` ADD `logoImageUrl` text;

ALTER TABLE `appointments` ADD `internalReferenceCode` varchar(64);--> statement-breakpoint
ALTER TABLE `appointments` ADD CONSTRAINT `appointments_internalReferenceCode_unique` UNIQUE(`internalReferenceCode`);--> statement-breakpoint
UPDATE `appointments`
SET `internalReferenceCode` = CONCAT('FB-RM-', UPPER(SUBSTRING(SHA2(CONCAT('formula-barber-reminder-v1|', `id`, '|', CAST(`scheduledAt` AS CHAR)), 256), 1, 24)))
WHERE `scheduledAt` >= '2026-08-21 03:00:00'
  AND `scheduledAt` < '2999-08-22 03:00:00'
  AND `internalReferenceCode` IS NULL;


CREATE TABLE `appointmentServices` (
	`id` int AUTO_INCREMENT NOT NULL,
	`appointmentId` int NOT NULL,
	`serviceId` int NOT NULL,
	`servicePrice` decimal(12,2) NOT NULL,
	`durationMinutes` int NOT NULL,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `appointmentServices_id` PRIMARY KEY(`id`),
	CONSTRAINT `appointment_services_unique` UNIQUE(`appointmentId`,`serviceId`)
);
--> statement-breakpoint
CREATE TABLE `clientFeedbacks` (
	`id` int AUTO_INCREMENT NOT NULL,
	`clientId` int NOT NULL,
	`appointmentId` int NOT NULL,
	`message` text NOT NULL,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `clientFeedbacks_id` PRIMARY KEY(`id`),
	CONSTRAINT `client_feedbacks_appointment_unique` UNIQUE(`appointmentId`)
);
--> statement-breakpoint
ALTER TABLE `appointmentServices` ADD CONSTRAINT `appointmentServices_appointmentId_appointments_id_fk` FOREIGN KEY (`appointmentId`) REFERENCES `appointments`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `appointmentServices` ADD CONSTRAINT `appointmentServices_serviceId_services_id_fk` FOREIGN KEY (`serviceId`) REFERENCES `services`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `clientFeedbacks` ADD CONSTRAINT `clientFeedbacks_clientId_clients_id_fk` FOREIGN KEY (`clientId`) REFERENCES `clients`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `clientFeedbacks` ADD CONSTRAINT `clientFeedbacks_appointmentId_appointments_id_fk` FOREIGN KEY (`appointmentId`) REFERENCES `appointments`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX `appointment_services_appointment` ON `appointmentServices` (`appointmentId`);--> statement-breakpoint
CREATE INDEX `client_feedbacks_client_created` ON `clientFeedbacks` (`clientId`,`createdAt`);--> statement-breakpoint
INSERT INTO `appointmentServices` (`appointmentId`, `serviceId`, `servicePrice`, `durationMinutes`, `createdAt`)
SELECT `appointments`.`id`, `appointments`.`serviceId`, `services`.`price`, COALESCE(`appointments`.`serviceDurationMinutes`, `services`.`durationMinutes`, 30), `appointments`.`createdAt`
FROM `appointments`
INNER JOIN `services` ON `services`.`id` = `appointments`.`serviceId`;


ALTER TABLE `ownerProfiles` ADD `dailyDigestScheduleTaskUid` varchar(65);--> statement-breakpoint
CREATE INDEX `owner_profiles_daily_digest_task` ON `ownerProfiles` (`dailyDigestScheduleTaskUid`);

ALTER TABLE `appointments` ADD `paymentPreference` varchar(20);

CREATE TABLE `appointmentConsumptionItems` (
	`id` int AUTO_INCREMENT NOT NULL,
	`appointmentId` int NOT NULL,
	`consumptionItemId` int NOT NULL,
	`itemName` varchar(160) NOT NULL,
	`unitPrice` decimal(12,2) NOT NULL,
	`quantity` int NOT NULL,
	`amount` decimal(12,2) NOT NULL,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `appointmentConsumptionItems_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `appointmentProducts` (
	`id` int AUTO_INCREMENT NOT NULL,
	`appointmentId` int NOT NULL,
	`productId` int NOT NULL,
	`productName` varchar(160) NOT NULL,
	`unitPrice` decimal(12,2) NOT NULL,
	`quantity` int NOT NULL,
	`amount` decimal(12,2) NOT NULL,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `appointmentProducts_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
ALTER TABLE `appointmentConsumptionItems` ADD CONSTRAINT `appointmentConsumptionItems_appointmentId_appointments_id_fk` FOREIGN KEY (`appointmentId`) REFERENCES `appointments`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `appointmentConsumptionItems` ADD CONSTRAINT `aci_consumption_item_fk` FOREIGN KEY (`consumptionItemId`) REFERENCES `consumptionItems`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `appointmentProducts` ADD CONSTRAINT `appointmentProducts_appointmentId_appointments_id_fk` FOREIGN KEY (`appointmentId`) REFERENCES `appointments`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `appointmentProducts` ADD CONSTRAINT `appointmentProducts_productId_products_id_fk` FOREIGN KEY (`productId`) REFERENCES `products`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX `appointment_consumption_appointment` ON `appointmentConsumptionItems` (`appointmentId`);--> statement-breakpoint
CREATE INDEX `appointment_products_appointment` ON `appointmentProducts` (`appointmentId`);

ALTER TABLE `cashEntries` ADD `paymentMethodId` int;--> statement-breakpoint
ALTER TABLE `cashEntries` ADD CONSTRAINT `cashEntries_paymentMethodId_paymentMethods_id_fk` FOREIGN KEY (`paymentMethodId`) REFERENCES `paymentMethods`(`id`) ON DELETE no action ON UPDATE no action;

ALTER TABLE `consumptionSales` MODIFY COLUMN `attendantId` int;--> statement-breakpoint
ALTER TABLE `consumptionSales` ADD `barberId` int;--> statement-breakpoint
ALTER TABLE `consumptionSales` ADD CONSTRAINT `consumptionSales_barberId_barbers_id_fk` FOREIGN KEY (`barberId`) REFERENCES `barbers`(`id`) ON DELETE no action ON UPDATE no action;

CREATE TABLE `barberScheduleSlots` (
	`id` int AUTO_INCREMENT NOT NULL,
	`barberId` int NOT NULL,
	`weekday` int NOT NULL,
	`slotTime` varchar(5) NOT NULL,
	`scope` enum('public','operational') NOT NULL DEFAULT 'public',
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `barberScheduleSlots_id` PRIMARY KEY(`id`),
	CONSTRAINT `barber_schedule_slot_unique` UNIQUE(`barberId`,`weekday`,`slotTime`,`scope`)
);
--> statement-breakpoint
ALTER TABLE `barberScheduleSlots` ADD CONSTRAINT `barberScheduleSlots_barberId_barbers_id_fk` FOREIGN KEY (`barberId`) REFERENCES `barbers`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX `barber_schedule_barber_weekday` ON `barberScheduleSlots` (`barberId`,`weekday`);

CREATE TABLE `barberScheduleLocks` (
	`id` int AUTO_INCREMENT NOT NULL,
	`barberId` int NOT NULL,
	`lockedDate` varchar(10) NOT NULL,
	`startTime` varchar(5) NOT NULL,
	`endTime` varchar(5) NOT NULL,
	`reason` varchar(180),
	`createdByUserId` int NOT NULL,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `barberScheduleLocks_id` PRIMARY KEY(`id`),
	CONSTRAINT `barber_schedule_lock_unique` UNIQUE(`barberId`,`lockedDate`,`startTime`,`endTime`)
);
--> statement-breakpoint
ALTER TABLE `barberScheduleLocks` ADD CONSTRAINT `barberScheduleLocks_barberId_barbers_id_fk` FOREIGN KEY (`barberId`) REFERENCES `barbers`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `barberScheduleLocks` ADD CONSTRAINT `barberScheduleLocks_createdByUserId_users_id_fk` FOREIGN KEY (`createdByUserId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX `barber_schedule_locks_date` ON `barberScheduleLocks` (`barberId`,`lockedDate`);

CREATE TABLE `clientCredentials` (
	`id` int AUTO_INCREMENT NOT NULL,
	`clientId` int NOT NULL,
	`userId` int NOT NULL,
	`email` varchar(320) NOT NULL,
	`passwordHash` varchar(512) NOT NULL,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `clientCredentials_id` PRIMARY KEY(`id`),
	CONSTRAINT `clientCredentials_email_unique` UNIQUE(`email`),
	CONSTRAINT `client_credentials_client_unique` UNIQUE(`clientId`),
	CONSTRAINT `client_credentials_user_unique` UNIQUE(`userId`)
);
--> statement-breakpoint
ALTER TABLE `clientCredentials` ADD CONSTRAINT `clientCredentials_clientId_clients_id_fk` FOREIGN KEY (`clientId`) REFERENCES `clients`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `clientCredentials` ADD CONSTRAINT `clientCredentials_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;

CREATE TABLE `passwordResetTokens` (
	`id` int AUTO_INCREMENT NOT NULL,
	`userId` int NOT NULL,
	`accountType` enum('owner','barber','attendant','customer') NOT NULL,
	`credentialId` int NOT NULL,
	`tokenHash` varchar(64) NOT NULL,
	`expiresAt` timestamp NOT NULL,
	`usedAt` timestamp,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `passwordResetTokens_id` PRIMARY KEY(`id`),
	CONSTRAINT `passwordResetTokens_tokenHash_unique` UNIQUE(`tokenHash`)
);
--> statement-breakpoint
ALTER TABLE `passwordResetTokens` ADD CONSTRAINT `passwordResetTokens_userId_users_id_fk` FOREIGN KEY (`userId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX `password_reset_lookup` ON `passwordResetTokens` (`userId`,`accountType`,`credentialId`);--> statement-breakpoint
CREATE INDEX `password_reset_expiry` ON `passwordResetTokens` (`expiresAt`);

ALTER TABLE `appointments` ADD `overlapMode` enum('standard','team_overlap') DEFAULT 'standard' NOT NULL;

CREATE TABLE `customerSubscriptions` (
	`id` int AUTO_INCREMENT NOT NULL,
	`clientId` int NOT NULL,
	`planCategory` varchar(160) NOT NULL,
	`planName` varchar(64) NOT NULL,
	`visitsPerMonth` int NOT NULL,
	`fullValue` decimal(12,2) NOT NULL,
	`discountPercent` int NOT NULL,
	`planValue` decimal(12,2) NOT NULL,
	`unitValue` decimal(12,2) NOT NULL,
	`paymentMethod` enum('pix') NOT NULL DEFAULT 'pix',
	`status` enum('pending','confirmed','rejected','cancelled') NOT NULL DEFAULT 'pending',
	`customerNote` text,
	`paymentReportedAt` timestamp,
	`confirmedAt` timestamp,
	`confirmedByUserId` int,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	`updatedAt` timestamp NOT NULL DEFAULT (now()) ON UPDATE CURRENT_TIMESTAMP,
	CONSTRAINT `customerSubscriptions_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
ALTER TABLE `customerSubscriptions` ADD CONSTRAINT `customerSubscriptions_clientId_clients_id_fk` FOREIGN KEY (`clientId`) REFERENCES `clients`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `customerSubscriptions` ADD CONSTRAINT `customerSubscriptions_confirmedByUserId_users_id_fk` FOREIGN KEY (`confirmedByUserId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX `customer_subscriptions_client_created` ON `customerSubscriptions` (`clientId`,`createdAt`);--> statement-breakpoint
CREATE INDEX `customer_subscriptions_status_created` ON `customerSubscriptions` (`status`,`createdAt`);

ALTER TABLE `customerSubscriptions` ADD `proofStorageKey` text;--> statement-breakpoint
ALTER TABLE `customerSubscriptions` ADD `proofOriginalName` varchar(180);--> statement-breakpoint
ALTER TABLE `customerSubscriptions` ADD `proofMimeType` varchar(80);--> statement-breakpoint
ALTER TABLE `customerSubscriptions` ADD `proofFileSize` int;--> statement-breakpoint
ALTER TABLE `customerSubscriptions` ADD `proofUploadedAt` timestamp;

ALTER TABLE `appointments` ADD `discountPercent` int DEFAULT 0 NOT NULL;--> statement-breakpoint
ALTER TABLE `appointments` ADD `discountAmount` decimal(12,2) DEFAULT '0.00' NOT NULL;

CREATE TABLE `rodoMessages` (
	`id` int AUTO_INCREMENT NOT NULL,
	`ownerUserId` int NOT NULL,
	`role` enum('user','assistant') NOT NULL,
	`content` text NOT NULL,
	`source` enum('chat','daily_digest') NOT NULL DEFAULT 'chat',
	`dedupeKey` varchar(96),
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `rodoMessages_id` PRIMARY KEY(`id`),
	CONSTRAINT `rodo_messages_owner_dedupe` UNIQUE(`ownerUserId`,`dedupeKey`)
);
--> statement-breakpoint
ALTER TABLE `rodoMessages` ADD CONSTRAINT `rodoMessages_ownerUserId_users_id_fk` FOREIGN KEY (`ownerUserId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX `rodo_messages_owner_created` ON `rodoMessages` (`ownerUserId`,`createdAt`);

CREATE TABLE `auditEvents` (
	`id` int AUTO_INCREMENT NOT NULL,
	`actorUserId` int,
	`action` varchar(80) NOT NULL,
	`entityType` varchar(80) NOT NULL,
	`entityId` int,
	`summary` varchar(500) NOT NULL,
	`metadata` text,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `auditEvents_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
CREATE TABLE `customerNotifications` (
	`id` int AUTO_INCREMENT NOT NULL,
	`clientId` int NOT NULL,
	`appointmentId` int,
	`kind` enum('reminder_24','reminder_2','change','cancel') NOT NULL,
	`title` varchar(180) NOT NULL,
	`body` text NOT NULL,
	`readAt` timestamp,
	`createdAt` timestamp NOT NULL DEFAULT (now()),
	CONSTRAINT `customerNotifications_id` PRIMARY KEY(`id`)
);
--> statement-breakpoint
ALTER TABLE `appointments` ADD `reminder24SentAt` timestamp;--> statement-breakpoint
ALTER TABLE `appointments` ADD `reminder2SentAt` timestamp;--> statement-breakpoint
ALTER TABLE `auditEvents` ADD CONSTRAINT `auditEvents_actorUserId_users_id_fk` FOREIGN KEY (`actorUserId`) REFERENCES `users`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `customerNotifications` ADD CONSTRAINT `customerNotifications_clientId_clients_id_fk` FOREIGN KEY (`clientId`) REFERENCES `clients`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE `customerNotifications` ADD CONSTRAINT `customerNotifications_appointmentId_appointments_id_fk` FOREIGN KEY (`appointmentId`) REFERENCES `appointments`(`id`) ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX `audit_events_created` ON `auditEvents` (`createdAt`);--> statement-breakpoint
CREATE INDEX `audit_events_entity` ON `auditEvents` (`entityType`,`entityId`);--> statement-breakpoint
CREATE INDEX `customer_notifications_client_created` ON `customerNotifications` (`clientId`,`createdAt`);