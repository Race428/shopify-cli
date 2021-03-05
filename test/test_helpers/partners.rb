# frozen_string_literal: true
module TestHelpers
  module Partners
    def setup
      ShopifyCli::DB.set(identity_exchange_token: "faketoken")
      super
    end

    def teardown
      ShopifyCli::DB.del(:identity_exchange_token)
      super
    end

    def stub_partner_req(query, variables: {}, status: 200, resp: {})
      filepaths = Dir[File.join(ShopifyCli::ROOT, "lib", "**", "graphql", "#{query}.graphql")]
      if filepaths.count > 1
        raise "Multiple queries in the codebase with filename #{query}.graphql, please rename your query."
      end
      stub_request(:post, "https://partners.shopify.com/api/cli/graphql").with(body: {
        query: File.read(filepaths.first).tr("\n", ""),
        variables: variables,
      }.to_json).to_return(status: status, body: resp.to_json)
    end

    def stub_shopify_org_confirmation(response: false)
      CLI::UI::Prompt
        .stubs(:confirm)
        .with(includes("Are you working on a 1P (1st Party) app?"), anything)
        .returns(response)
    end
  end
end
