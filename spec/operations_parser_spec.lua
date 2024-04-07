local parser = require("rocks.operations.parser")
describe("operations.parser", function()
    describe("parse_install_args", function()
        it("Parses rocks.InstallSpec from arg list", function()
            assert.same({ opt = true }, parser.parse_install_args({ "opt=true" }).spec)
            assert.same({ opt = false }, parser.parse_install_args({ "opt=false" }).spec)
        end)

        it("Detects invalid args", function()
            assert.same({ "op=true" }, parser.parse_install_args({ "opt=true", "op=true" }).invalid_args)
        end)

        it("Single arg without a field prefix is version", function()
            assert.same({ version = "1.0.0", opt = true }, parser.parse_install_args({ "1.0.0", "opt=true" }).spec)
            assert.same({ version = "1.0.0", opt = true }, parser.parse_install_args({ "opt=true", "1.0.0" }).spec)
        end)

        it("Multiple args without a field prefix are invalid", function()
            assert.same({ "1.0.0", "foo" }, parser.parse_install_args({ "1.0.0", "opt=true", "foo" }).invalid_args)
        end)

        it("Non-boolean opt is invalid", function()
            assert.same({ opt = true }, parser.parse_install_args({ "opt=true" }).spec)
            assert.same({ opt = true }, parser.parse_install_args({ "opt=1" }).spec)
            assert.same({ opt = false }, parser.parse_install_args({ "opt=false" }).spec)
            assert.same({ opt = false }, parser.parse_install_args({ "opt=0" }).spec)
            assert.same({ "opt=3" }, parser.parse_install_args({ "opt=3" }).invalid_args)
            assert.same({ "opt=otherwise" }, parser.parse_install_args({ "opt=otherwise" }).invalid_args)
        end)

        it("Does not accept conflicting args", function()
            assert.same(
                { "opt=false", "opt=true" },
                parser.parse_install_args({ "opt=true", "opt=false" }).conflicting_args
            )
        end)
    end)
end)