# 📚 Documentation Correction Plan

## 🚨 **Critical Documentation Gaps Identified**

Based on research into live production contracts (SundaeSwap, JPG.store, Minswap, LenFi), our documentation contains **outdated patterns** that prevented proper transaction context access.

## 🔧 **Required Documentation Updates**

### **1. Update `docs/language/validators.md`**

**BEFORE** (Incorrect):

```aiken
validator my_script {
  spend(
    datum: Option<MyDatum>,
    redeemer: MyRedeemer,
    context: ScriptContext  // ❌ WRONG - Not current Aiken
  ) -> Bool {
    context.transaction.extra_signatories  // ❌ WRONG - Doesn't work
  }
}
```

**AFTER** (Correct - Production Pattern):

```aiken
validator my_script {
  spend(
    datum: Option<MyDatum>,
    redeemer: MyRedeemer,
    _own_ref: OutputReference,
    self: Transaction,  // ✅ CORRECT - Current Aiken
  ) -> Bool {
    list.has(self.extra_signatories, owner)  // ✅ CORRECT - Works
  }
}
```

### **2. Update `docs/language/syntax.md`**

Add **critical imports section**:

```aiken
// Required for transaction validation
use aiken/collection/list
use cardano/transaction.{Transaction, OutputReference, Output}
use cardano/address.{VerificationKey}
use cardano/assets.{ada_policy_id, ada_asset_name, quantity_of}
```

### **3. Update `aiken.toml` Examples**

**ALL examples need**:

```toml
[[dependencies]]
name = "aiken-lang/stdlib"
version = "2.1.0"
source = "github"
```

### **4. Fix `docs/security/validator-risks.md`**

Replace non-working examples with **validated patterns**:

```aiken
// ✅ SIGNATURE VERIFICATION (Production Pattern)
let authorized = list.has(self.extra_signatories, owner)

// ✅ PAYMENT VERIFICATION (Production Pattern)
let payment_valid = list.any(self.outputs, fn(output) {
  when output.address.payment_credential is {
    VerificationKey(hash) -> hash == recipient
    _ -> False
  }
})

// ✅ TIME VALIDATION (Research Needed)
// TODO: Find correct validity_range syntax
```

### **5. Update All Code Examples**

**Files to Fix**:

- `docs/code-examples/escrow-contract.md`
- `docs/code-examples/dao-governance.md`
- `docs/code-examples/staking-contract.md`
- `docs/code-examples/token-contract.md`

**Pattern**: Replace all `context: ScriptContext` with `self: Transaction`

## 🎯 **Validation Requirements**

Before updating documentation:

1. **Test every code example** - Must compile with `aiken check`
2. **Verify against live contracts** - Match patterns used by SundaeSwap, etc.
3. **Include stdlib dependency** - All examples need working `aiken.toml`
4. **Performance validation** - Include actual benchmarks

## 🚀 **Priority Order**

1. **HIGH**: Fix validator signatures (prevents compilation)
2. **HIGH**: Add stdlib dependencies (enables imports)
3. **MEDIUM**: Update security examples (enables real security)
4. **LOW**: Clean up obsolete references

## 📈 **Success Metrics**

- [ ] All documentation examples compile successfully
- [ ] New developers can follow docs without hitting context access issues
- [ ] Security patterns actually work in practice
- [ ] Examples match production contract patterns

This correction will transform our documentation from **misleading** to **production-accurate**.
