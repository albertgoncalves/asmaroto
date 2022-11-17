#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

#define CAP_BUFFER  (1 << 12)
#define CAP_THREADS (1 << 4)
#define CAP_STACKS  (1 << 4)

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
    void*   rsp;
    void*   rbp;
    Bool    alive;
    Thread* next;
    Thread* last;
};

static Stack STACKS[CAP_STACKS] = {0};
static u32   LEN_STACKS = 0;

static Thread THREADS[CAP_THREADS] = {0};
static u32    LEN_THREADS = 0;

extern Thread* CURRENT_THREAD;

static Thread* QUEUE = NULL;

static u32 FINISHED = 0;

Thread* new_thread(void (*)(void));
Thread* new_thread(void (*resume)(void)) {
    printf("        [ Creating thread ]\n");
    EXIT_IF(CAP_THREADS <= LEN_THREADS);
    Thread* thread = &THREADS[LEN_THREADS++];
    thread->resume = resume;
    void* stack = (void*)&STACKS[LEN_STACKS++].buffer[CAP_BUFFER];
    thread->rbp = stack;
    thread->rsp = stack;
    thread->alive = TRUE;

    thread->next = NULL;
    thread->last = NULL;
    if (!QUEUE) {
        QUEUE = thread;
    } else if (!QUEUE->next) {
        EXIT_IF(QUEUE->last);
        QUEUE->next = thread;
        QUEUE->last = thread;
    } else {
        EXIT_IF(!QUEUE->last);
        EXIT_IF(QUEUE->last->next);
        QUEUE->last->next = thread;
        QUEUE->last = thread;
    }

    return thread;
}

void push_thread(Thread*, void*);
void push_thread(Thread* thread, void* data) {
    --thread->rsp;
    *(void**)thread->rsp = data;
}

__attribute__((noreturn)) void scheduler(void);
__attribute__((noreturn)) void scheduler(void) {
    printf("    [ Scheduler resumed ]\n");
    if (!QUEUE) {
        printf("    [ Queue is empty ]\n");
        goto end;
    }

    CURRENT_THREAD = QUEUE;
    for (;;) {
        EXIT_IF(!CURRENT_THREAD);
        if (CURRENT_THREAD->alive) {
            break;
        }
        printf("        [ Found dead thread ]\n");
        FINISHED++;
        if (!CURRENT_THREAD->next) {
            EXIT_IF(CURRENT_THREAD->last);
            goto end;
        }
        CURRENT_THREAD = CURRENT_THREAD->next;
    }

    {
        Thread* last = QUEUE->last;
        QUEUE = CURRENT_THREAD->next;
        if (QUEUE) {
            QUEUE->last = last;
            QUEUE->last->next = CURRENT_THREAD;
            QUEUE->last = CURRENT_THREAD;
        } else {
            EXIT_IF(!CURRENT_THREAD->alive);
            QUEUE = CURRENT_THREAD;
        }
    }

    CURRENT_THREAD->next = NULL;
    CURRENT_THREAD->last = NULL;

    printf("    [ Running thread %p ]\n", (void*)CURRENT_THREAD);
    CURRENT_THREAD->resume();

end:
    printf("    [ Scheduler finished ]\n");
    EXIT_IF(LEN_THREADS != FINISHED);
    _exit(OK);
}
