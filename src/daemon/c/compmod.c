
#include <lua.h>
#include <lualib.h>
#include <lauxlib.h>

#include "compmod.h"

void luaL_openlib(lua_State *L, const char *libname, const luaL_reg *l, int nup)
{
    lua_getglobal(L, libname);
    if (lua_isnil(L, -1)) {
        lua_pop(L, 1);
        lua_newtable(L);
    }
    luaL_setfuncs(L, l, nup);
    lua_setglobal(L, libname);
}

int luaL_typerror(lua_State *L, int narg, const char *tname) {
    return luaL_error(L, "type error: %d %s", narg, tname);
}

int lua_strlen(lua_State *L, int index){
    return lua_rawlen(L, index);
}

int luaL_checkint (lua_State *L, int arg){
    return (int)luaL_checkinteger(L, arg);
}