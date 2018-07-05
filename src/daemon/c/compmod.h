#ifndef COMP_MOD
#define COMP_MOD

#define luaL_reg luaL_Reg

void luaL_openlib(lua_State *L, const char *libname, const luaL_reg *l, int nup);
int luaL_typerror(lua_State *L, int narg, const char *tname);
int lua_strlen(lua_State *L, int index);
int luaL_checkint (lua_State *L, int arg);

#endif


