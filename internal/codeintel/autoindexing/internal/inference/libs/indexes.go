package libs

import (
	"fmt"

	lua "github.com/yuin/gopher-lua"
	luar "layeh.com/gopher-luar"

	"github.com/sourcegraph/sourcegraph/internal/conf"
	"github.com/sourcegraph/sourcegraph/internal/luasandbox/util"
	"github.com/sourcegraph/sourcegraph/lib/errors"
)

var Indexes = indexesAPI{}

type indexesAPI struct{}

var defaultIndexers = map[string]string{
	"clang":      "sourcegraph/lsif-clang",
	"go":         "sourcegraph/scip-go",
	"java":       "sourcegraph/scip-java",
	"python":     "sourcegraph/scip-python",
	"rust":       "sourcegraph/scip-rust",
	"typescript": "sourcegraph/scip-typescript",
	"ruby":       "sourcegraph/scip-ruby",
}

// To update, run `DOCKER_USER=... DOCKER_PASS=... ./update-shas.sh`
var defaultIndexerSHAs = map[string]string{
	"sourcegraph/scip-go":         "sha256:4f82e2490c4385a3c47ac0d062c9c53ce5a0bfc5acf0c4032ad07486b39163ec",
	"sourcegraph/lsif-clang":      "sha256:ea814e5ab5c6e1e6ab4d001e4f4afddcc7b44128edbeeedf1d97da553813a4c8",
	"sourcegraph/lsif-rust":       "sha256:83cb769788987eb52f21a18b62d51ebb67c9436e1b0d2e99904c70fef424f9d1",
	"sourcegraph/scip-rust":       "sha256:adf0047fc3050ba4f7be71302b42c74b49901f38fb40916d94ac5fc9181ac078",
	"sourcegraph/scip-java":       "sha256:9c6760bbb3a44ebe1ceb9c16b5f7b85c07f0b073d772c1715e635235ba231129",
	"sourcegraph/scip-python":     "sha256:ab7f4b6c42870761248fa0d2c4774e2e1a6f5b1b65dd06f75f064a9418625b83",
	"sourcegraph/scip-typescript": "sha256:4c9b65a449916bf2d8716c8b4b0a45666cd303a05b78e02980d25b23c1e55e92",
	"sourcegraph/scip-ruby":       "sha256:ef53e5f1450330ddb4a3edce963b7e10d900d44ff1e7de4960680289ac25f319",
}

func DefaultIndexerForLang(language string) (string, bool) {
	indexer, ok := defaultIndexers[language]
	if !ok {
		return "", false
	}

	sha, ok := defaultIndexerSHAs[indexer]
	if !ok {
		panic(fmt.Sprintf("no SHA set for indexer %q", indexer))
	}

	return fmt.Sprintf("%s@%s", indexer, sha), true
}

func (api indexesAPI) LuaAPI() map[string]lua.LGFunction {
	return map[string]lua.LGFunction{
		"get": util.WrapLuaFunction(func(state *lua.LState) error {
			language := state.CheckString(1)

			if indexer, ok := conf.SiteConfig().CodeIntelAutoIndexingIndexerMap[language]; ok {
				state.Push(luar.New(state, indexer))
				return nil
			}

			if indexer, ok := DefaultIndexerForLang(language); ok {
				state.Push(luar.New(state, indexer))
				return nil
			}

			return errors.Newf("no indexer is registered for %q", language)
		}),
	}
}
