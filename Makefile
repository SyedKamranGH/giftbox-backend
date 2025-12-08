.PHONY: help migrate-up migrate-down migrate-force migrate-version seed

migrate-up:
	@echo "Running migrations..."
	@./scripts/migrate.sh up

migrate-down:
	@echo "Rolling back migrations..."
	@./scripts/migrate.sh down

migrate-force:
	@echo "Forcing migration version..."
	@./scripts/migrate.sh force $(VERSION)

migrate-version:
	@./scripts/migrate.sh version

# seed:
# 	@echo "Seeding database..."
# 	@docker-compose exec -T postgres psql -U giftbox_user -d giftbox_db < scripts/seed.sql
# 	@echo "✅ Database seeded"