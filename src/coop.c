#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

#define CAP_BUFFER  (1 << 12)
#define CAP_THREADS (1 << 3)
#define CAP_STACKS  (1 << 3)

typedef uint32_t u32;
typedef uint64_t u64;

typedef enum {
    FALSE = 0,
    TRUE,
} Bool;

#define OK    0
#define ERROR 1

#define EXIT_IF(condition)            \
    do {                              \
        if (condition) {              \
            printf("%s:%s:%d `%s`\n", \
                   __FILE__,          \
                   __func__,          \
                   __LINE__,          \
                   #condition);       \
            _exit(ERROR);             \
        }                             \
    } while (0)

typedef struct {
    u64 buffer[CAP_BUFFER];
} Stack;

typedef struct Thread Thread;

struct Thread {
    void (*resume)(void);
    void* rsp;
    void* rbp;
    Bool  alive;
};

static Stack STACKS[CAP_STACKS] = {0};
static u64   LEN_STACKS = 0;

static Thread THREADS[CAP_THREADS] = {0};
static u64    LEN_THREADS = 0;

static u32 OFFSET = 0;

extern Thread* CURRENT_THREAD;

Thread* new_thread(void (*)(void));
Thread* new_thread(void (*resume)(void)) {
    EXIT_IF(CAP_THREADS <= LEN_THREADS);
    Thread* thread = &THREADS[LEN_THREADS++];
    thread->resume = resume;
    void* stack = (void*)&STACKS[LEN_STACKS++].buffer[CAP_BUFFER];
    thread->rbp = stack;
    thread->rsp = stack;
    thread->alive = TRUE;
    return thread;
}

void push_thread(Thread*, void*);
void push_thread(Thread* thread, void* data) {
    --thread->rsp;
    *(void**)thread->rsp = data;
}

__attribute__((noreturn)) void scheduler(void);
__attribute__((noreturn)) void scheduler(void) {
    printf(" [Scheduler resumed]\n");
    for (u32 i = 0; i < CAP_THREADS; ++i) {
        Thread* thread = &THREADS[OFFSET];
        OFFSET = (OFFSET + 1) % CAP_THREADS;
        if (thread->alive) {
            printf(" [Running thread %p]\n", (void*)thread);
            CURRENT_THREAD = thread;
            thread->resume();
        }
    }
    printf(" [Scheduler finished]\n");
    _exit(OK);
}
