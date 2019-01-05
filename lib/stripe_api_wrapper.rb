class StripeApiWrapper
  class << self
    def charge(athlete, subscription_plan, stripe_token, stripe_email)
      Rails.logger.info("Creating subscription for athlete #{athlete.id}")

      customer = retrieve_customer(athlete, stripe_token, stripe_email)
      create_charge(customer, subscription_plan)
    end

    def renew(stripe_customer, pro_subscription_plan)
      Rails.logger.info("Automatically renewing subscription for athlete #{stripe_customer.athlete_id}.")

      create_charge(stripe_customer, pro_subscription_plan)
    end

    private

    def create_charge(customer, subscription_plan)
      Stripe::Charge.create(
        amount: (subscription_plan.amount * 100).to_i,
        currency: Settings.app.currency,
        customer: customer.id,
        description: subscription_plan.name,
        metadata: {
          "Subscription Plan ID" => subscription_plan.id,
          "Subscription Plan Name" => subscription_plan.name
        }
      )
    end

    def retrieve_customer(athlete, stripe_token, stripe_email) # rubocop:disable AbcSize, CyclomaticComplexity, PerceivedComplexity, MethodLength, LineLength
      stripe_customer = StripeCustomer.find_by(athlete_id: athlete.id)

      # Check if the saved StripeCustomer still actually exists on Stripe.
      begin
        customer = Stripe::Customer.retrieve(stripe_customer.id) unless stripe_customer.nil? || stripe_customer.id.blank?
      rescue Stripe::StripeError => e
        raise unless e.http_status == 404

        customer = nil
      end

      # Create a new customer if it does not exist yet or it has been deleted.
      if customer.blank? || customer.deleted?
        customer_metadata = {
          "Athelte ID" => athlete.id,
          "Email" => athlete.email,
          "First Name" => athlete.athlete_info.firstname,
          "Last Name" => athlete.athlete_info.lastname,
          "Strava Profile URL" => athlete.profile_url,
          "Strafforts Profile URL" => "#{Settings.app.production_url}/athletes/#{athlete.id}"
        }
        customer = Stripe::Customer.create(
          source: stripe_token,
          email: stripe_email,
          metadata: customer_metadata
        )

        # Create a new record in stripe_customers table.
        stripe_customer = StripeCustomer.where(athlete_id: athlete.id).first_or_create
        stripe_customer.id = customer.id
        stripe_customer.email = customer.email
        stripe_customer.save!
      else
        new_card = Stripe::Token.retrieve(stripe_token) # Retrieve the card fingerprint using the stripe_card_token.
        card_fingerprint = new_card.try(:card).try(:fingerprint)
        card_exp_month = new_card.try(:card).try(:exp_month)
        card_exp_year = new_card.try(:card).try(:exp_year)

        # Check if the new card already exists.
        default_cards = customer.sources.all(object: "card").data
                                .select do |card|
                                  ((card.fingerprint == card_fingerprint) && (card.exp_month == card_exp_month) && (card.exp_year == card_exp_year))
                                end
        default_card = default_cards.last
        default_card ||= customer.sources.create(source: stripe_token)
        customer.default_card = default_card.id # Set the new card as the default card.
        customer.save
      end

      stripe_customer
    end
  end
end
