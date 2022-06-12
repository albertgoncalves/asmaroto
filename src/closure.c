#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#define CAP_LISTS  (1 << 2)
#define CAP_SCOPES (1 << 2)
#define CAP_BUFFER (1 << 3)

typedef int32_t i32;
typedef int64_t i64;

typedef uint32_t u32;
typedef uint64_t u64;

#define OK    0
#define ERROR 1

#define EXIT()                                              \
    {                                                       \
        printf("%s:%s:%d\n", __FILE__, __func__, __LINE__); \
        _exit(ERROR);                                       \
    }

#define EXIT_IF(condition)                                                   \
    if (condition) {                                                         \
        printf("%s:%s:%d `%s`\n", __FILE__, __func__, __LINE__, #condition); \
        _exit(ERROR);                                                        \
    }

typedef struct List List;

struct List {
    char* key_chars;
    u64   key_len;
    i64   value;
    List* next;
};

typedef struct Scope Scope;

struct Scope {
    List*  list;
    Scope* parent;
};

typedef struct {
    List  lists[CAP_LISTS];
    u64   len_lists;
    Scope scopes[CAP_SCOPES];
    u64   len_scopes;
    i64   buffer[CAP_BUFFER];
    u64   len_buffer;
} Memory;

static Memory MEMORY = {0};

void   memory_init(void);
i64*   alloc_buffer_2(i64, i64);
Scope* scope_new(void);
Scope* scope_new_from(Scope*);
i64    scope_lookup(Scope*, char*, u64);
void   scope_insert(Scope*, char*, u64, i64);
void   scope_update(Scope*, char*, u64, i64);

void memory_init(void) {
    memset(&MEMORY, 0, sizeof(Memory));
}

i64* alloc_buffer_2(i64 a, i64 b) {
    EXIT_IF(CAP_BUFFER <= (MEMORY.len_buffer + 1));
    MEMORY.buffer[MEMORY.len_buffer] = a;
    MEMORY.buffer[MEMORY.len_buffer + 1] = b;
    i64* buffer = &MEMORY.buffer[MEMORY.len_buffer];
    MEMORY.len_buffer += 2;
    return buffer;
}

Scope* scope_new(void) {
    return scope_new_from(NULL);
}

Scope* scope_new_from(Scope* parent) {
    EXIT_IF(CAP_SCOPES <= MEMORY.len_scopes);
    Scope* scope = &MEMORY.scopes[MEMORY.len_scopes++];
    scope->parent = parent;
    printf("  - %s\n      parent:%p -> child:%p\n",
           __func__,
           (void*)parent,
           (void*)scope);
    return scope;
}

#define EQ(a_chars, a_len, b_chars, b_len) \
    ((a_len == b_len) && (!memcmp(a_chars, b_chars, a_len)))

#define DEBUG_SCOPE()                           \
    printf("  - %s\n      scope:%p key:%.*s\n", \
           __func__,                            \
           (void*)scope,                        \
           (i32)key_len,                        \
           key_chars)

i64 scope_lookup(Scope* scope, char* key_chars, u64 key_len) {
    DEBUG_SCOPE();
    while (scope) {
        List* list = scope->list;
        while (list) {
            if (EQ(key_chars, key_len, list->key_chars, list->key_len)) {
                return list->value;
            }
            list = list->next;
        }
        scope = scope->parent;
    }
    EXIT();
}

void scope_insert(Scope* scope, char* key_chars, u64 key_len, i64 value) {
    DEBUG_SCOPE();
    EXIT_IF(CAP_LISTS <= MEMORY.len_lists);
    List* list = &MEMORY.lists[MEMORY.len_lists++];
    list->key_chars = key_chars;
    list->key_len = key_len;
    list->value = value;
    if (!scope->list) {
        scope->list = list;
        return;
    }
    list->next = scope->list;
    scope->list = list;
    return;
}

void scope_update(Scope* scope, char* key_chars, u64 key_len, i64 value) {
    DEBUG_SCOPE();
    while (scope) {
        List* list = scope->list;
        while (list) {
            if (EQ(key_chars, key_len, list->key_chars, list->key_len)) {
                list->value = value;
                return;
            }
            list = list->next;
        }
        scope = scope->parent;
    }
    EXIT();
}
