# Contributing to Bucu Core

Terima kasih atas minat Anda untuk berkontribusi pada Bucu Core! 🎉

## Prinsip Kontribusi

1. **Stabilitas First** - Core harus tetap stabil dan backward compatible
2. **API Parity** - Lua dan JavaScript harus 1:1 identical
3. **Minimal Scope** - Core tetap ringan, fitur gameplay di modules
4. **Clear Documentation** - Semua perubahan harus terdokumentasi

## Cara Berkontribusi

### 1. Fork & Clone

```bash
git clone https://github.com/your-username/bucucore-framework.git
cd bucucore-framework
```

### 2. Buat Branch

```bash
git checkout -b feature/nama-fitur
```

### 3. Development

- Ikuti code style yang ada
- Tulis kode yang clean dan readable
- Tambahkan comments untuk logic yang complex
- Test perubahan Anda di FiveM server

### 4. Testing

```bash
# Pastikan tidak ada error
# Test di FiveM server
# Verify API parity (Lua & JS)
```

### 5. Commit

```bash
git add .
git commit -m "feat: deskripsi singkat perubahan"
```

**Commit Message Format:**
- `feat:` - Fitur baru
- `fix:` - Bug fix
- `docs:` - Perubahan dokumentasi
- `refactor:` - Refactoring code
- `test:` - Menambah tests
- `chore:` - Maintenance tasks

### 6. Push & Pull Request

```bash
git push origin feature/nama-fitur
```

Buat Pull Request di GitHub dengan deskripsi lengkap.

## Code Style

### Lua

```lua
-- Function names: camelCase
function MyClass:doSomething()
    -- Local variables: camelCase
    local myVariable = "value"
    
    -- Constants: UPPER_CASE
    local MAX_PLAYERS = 32
    
    -- Private methods: _prefixed
    function MyClass:_privateMethod()
    end
end
```

### JavaScript

```javascript
// Function names: camelCase
function doSomething() {
    // Variables: camelCase
    const myVariable = "value";
    
    // Constants: UPPER_CASE
    const MAX_PLAYERS = 32;
    
    // Private methods: _prefixed
    _privateMethod() {
    }
}
```

## API Parity Checklist

Saat menambah fitur baru:

- [ ] Implementasi di Lua
- [ ] Implementasi di JavaScript
- [ ] Method signature identik
- [ ] Behavior identik
- [ ] Error handling sama
- [ ] Documentation untuk kedua bahasa

## Testing Checklist

- [ ] Code berjalan tanpa error
- [ ] Tidak ada breaking changes
- [ ] API parity terjaga
- [ ] Performance acceptable
- [ ] Memory leaks checked
- [ ] Error handling tested

## Documentation

Setiap perubahan harus didokumentasikan:

1. **Code Comments** - Jelaskan logic yang complex
2. **README** - Update jika ada perubahan API
3. **CHANGELOG** - Tambahkan entry untuk perubahan

## Pull Request Guidelines

### Good PR:
- Fokus pada satu fitur/fix
- Deskripsi jelas
- Code clean dan tested
- Documentation updated
- No breaking changes (kecuali v2.x)

### Bad PR:
- Multiple unrelated changes
- No description
- Untested code
- Missing documentation
- Breaking changes tanpa notice

## Core Scope Rules

**BOLEH di Core:**
- Event system improvements
- Performance optimizations
- Bug fixes
- Developer experience improvements
- Platform adapter enhancements

**TIDAK BOLEH di Core:**
- Inventory system
- Job system
- Money/economy
- UI components
- Vehicle logic
- Gameplay features

Fitur gameplay harus dibuat sebagai **modules** eksternal.

## Questions?

- Open an issue untuk diskusi
- Join Discord community
- Email: dev@bucu-core.com

## License

Dengan berkontribusi, Anda setuju bahwa kontribusi Anda akan dilisensikan di bawah MIT License.

---

**Terima kasih telah berkontribusi! 🚀**
