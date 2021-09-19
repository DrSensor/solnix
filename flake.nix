{
  description = "A collection of Solana templates";
  outputs = { self }: {

    templates.dapp-scaffold = {
      path = ./dapp-scaffold;
      description = "Scaffolding for a dapp built on Solana";
    };

    templates.metaplex = {
      path = ./metaplex;
      description = "Protocol and application framework for decentralized NFT minting, storefronts, and sales.";
    };

  };
}
