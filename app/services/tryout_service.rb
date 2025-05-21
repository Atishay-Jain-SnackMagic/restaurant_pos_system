class TryoutService
  def call
    # l1 = User.first
    # l2 = User.first

    # l1.update(is_admin: true)
    # # l1.save!
    # l2.update(is_admin: true)

    # User Load (0.9ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT 1 /*application='RestaurantPosSystem'*/
    # User Load (0.3ms)  SELECT "users".* FROM "users" ORDER BY "users"."id" ASC LIMIT 1 /*application='RestaurantPosSystem'*/
    # TRANSACTION (0.2ms)  BEGIN /*application='RestaurantPosSystem'*/
    # User Exists? (1.1ms)  SELECT 1 AS one FROM "users" WHERE LOWER("users"."email") = LOWER('abc@example.com') AND "users"."id" != 1 LIMIT 1 /*application='RestaurantPosSystem'*/
    # User Update (0.6ms)  UPDATE "users" SET "is_admin" = TRUE, "updated_at" = '2025-05-19 11:22:05.388888', "lock_version" = 1 WHERE "users"."id" = 1 AND "users"."lock_version" IS NULL /*application='RestaurantPosSystem'*/
    # TRANSACTION (1.4ms)  COMMIT /*application='RestaurantPosSystem'*/
    # TRANSACTION (0.2ms)  BEGIN /*application='RestaurantPosSystem'*/
    # User Exists? (0.6ms)  SELECT 1 AS one FROM "users" WHERE LOWER("users"."email") = LOWER('abc@example.com') AND "users"."id" != 1 LIMIT 1 /*application='RestaurantPosSystem'*/
    # User Update (0.2ms)  UPDATE "users" SET "is_admin" = TRUE, "updated_at" = '2025-05-19 11:22:05.395389', "lock_version" = 1 WHERE "users"."id" = 1 AND "users"."lock_version" IS NULL /*application='RestaurantPosSystem'*/
    # TRANSACTION (0.1ms)  ROLLBACK /*application='RestaurantPosSystem'*/
    # app/services/tryout_service.rb:8:in 'TryoutService#call': Attempted to update a stale object: User. (ActiveRecord::StaleObjectError)

    User.transaction do
      # ActiveRecord::Base.connection.execute("LOCK TABLE users IN ACCESS EXCLUSIVE MODE")
      User.first.with_lock do
        sleep 10000
      end
    end
  end
end
