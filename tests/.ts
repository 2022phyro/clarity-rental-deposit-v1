import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Can create rental agreement",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const tenant = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('rental-deposit', 'create-rental', [
                types.principal(tenant.address),
                types.uint(1000)
            ], deployer.address)
        ]);
        
        block.receipts[0].result.expectOk();
    },
});

Clarinet.test({
    name: "Can pay deposit",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const tenant = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('rental-deposit', 'create-rental', [
                types.principal(tenant.address),
                types.uint(1000)
            ], deployer.address),
            Tx.contractCall('rental-deposit', 'pay-deposit', [
                types.principal(deployer.address)
            ], tenant.address)
        ]);
        
        block.receipts[0].result.expectOk();
        block.receipts[1].result.expectOk();
    },
});

Clarinet.test({
    name: "Can return deposit",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const tenant = accounts.get('wallet_1')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('rental-deposit', 'create-rental', [
                types.principal(tenant.address),
                types.uint(1000)
            ], deployer.address),
            Tx.contractCall('rental-deposit', 'pay-deposit', [
                types.principal(deployer.address)
            ], tenant.address),
            Tx.contractCall('rental-deposit', 'return-deposit', [
                types.principal(tenant.address)
            ], deployer.address)
        ]);
        
        block.receipts[0].result.expectOk();
        block.receipts[1].result.expectOk();
        block.receipts[2].result.expectOk();
    },
});
