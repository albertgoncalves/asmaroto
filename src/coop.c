#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

#define CAP_BUFFER   (1 << 12)
#define CAP_THREADS  (1 << 4)
#define CAP_STACKS   (1 << 4)
#define CAP_CHANNELS (1 << 4)
#define CAP_WAITING  (1 << 4)

typedef uint32_t u32;
typedef uint64_t u64;

typedef enum {
    FALSE = 0,
    TRUE,
} Bool;

#define OK    0
#define ERROR 1

#define DEBUG 1

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
    void* buffer[CAP_BUFFER];
} Stack;

typedef enum {
    DEAD = 0,
    PAUSED,
    READY,
} Status;

typedef struct Thread Thread;

struct Thread {
    void (*resume)(void);
    void**  rsp;
    void**  rbp;
    Thread* next;
    Thread* last;
    Status  status;
};

typedef struct Waiting Waiting;

struct Waiting {
    Thread*  thread;
    Waiting* next;
    Waiting* last;
};

typedef struct Channel Channel;

struct Channel {
    Channel* next;
    Channel* last;
    void*    data;
    Bool     ready;
    Waiting* waiting;
};

static Stack STACKS[CAP_STACKS];
static u32   LEN_STACKS = 0;

static Thread THREADS[CAP_THREADS];
static u32    LEN_THREADS = 0;

static Channel CHANNELS[CAP_CHANNELS];
static u32     LEN_CHANNELS = 0;

static Waiting WAITING[CAP_WAITING];
static u32     LEN_WAITING = 0;

extern Thread* CURRENT_THREAD;

static Thread* QUEUE = NULL;

static u32 FINISHED = 0;

static void push_thread(Thread* threads, Thread* last) {
#if DEBUG
    printf("  [ Appending thread (%p) ]\n", (void*)last);
#endif
    EXIT_IF(!threads);
    EXIT_IF(!last);
    if (!threads->next) {
        EXIT_IF(threads->last);
        threads->next = last;
        threads->last = last;
    } else {
        EXIT_IF(!threads->last);
        threads->last->next = last;
        threads->last = last;
    }
}

Thread* new_thread(void (*)(void));
Thread* new_thread(void (*resume)(void)) {
#if DEBUG
    printf("  [ Creating thread ]\n");
#endif
    EXIT_IF(CAP_THREADS <= LEN_THREADS);
    Thread* thread = &THREADS[LEN_THREADS++];
    thread->resume = resume;
    void** stack = &STACKS[LEN_STACKS++].buffer[CAP_BUFFER];
    thread->rbp = stack;
    thread->rsp = stack;
    thread->status = READY;

    thread->next = NULL;
    thread->last = NULL;
    if (!QUEUE) {
        QUEUE = thread;
    } else {
        push_thread(QUEUE, thread);
    }
    return thread;
}

void kill_thread(Thread*);
void kill_thread(Thread* thread) {
#if DEBUG
    printf("  [ Killing thread ]\n");
#endif
    thread->status = DEAD;
    ++FINISHED;
}

void push_thread_stack(Thread*, void*);
void push_thread_stack(Thread* thread, void* data) {
#if DEBUG
    printf("  [ Pushing data onto thread stack ]\n");
#endif
    --thread->rsp;
    *thread->rsp = data;
}

Channel* new_channel(void);
Channel* new_channel(void) {
#if DEBUG
    printf("  [ Creating channel ]\n");
#endif
    EXIT_IF(CAP_CHANNELS <= LEN_CHANNELS);
    Channel* channel = &CHANNELS[LEN_CHANNELS++];
    channel->ready = FALSE;
    channel->next = NULL;
    channel->last = NULL;
    return channel;
}

static void pop_waiting(Channel* channel) {
#if DEBUG
    printf("  [ Popping thread from wait list ]\n");
#endif
    EXIT_IF(!channel);
    EXIT_IF(!channel->waiting);
    EXIT_IF(!channel->waiting->thread);
    channel->waiting->thread->status = READY;
    Waiting* next = channel->waiting->next;
    Waiting* last = channel->waiting->last;
    if (!next) {
        EXIT_IF(last);
        channel->waiting = NULL;
        return;
    }
    if (next == last) {
        channel->waiting = next;
        channel->next = NULL;
        channel->last = NULL;
        return;
    }
    channel->waiting = next;
    channel->waiting->last = last;
}

void push_channel(Channel*, void*);
void push_channel(Channel* channel, void* data) {
#if DEBUG
    if (data) {
        printf("  [ Pushing message (%p) to channel ]\n", data);
    } else {
        printf("  [ Pushing message (0x0) to channel ]\n");
    }
#endif
    EXIT_IF(!channel);
    if (channel->waiting) {
        pop_waiting(channel);
    }
    if (!channel->ready) {
        channel->data = data;
        channel->ready = TRUE;
        return;
    }
    Channel* last = new_channel();
    last->data = data;
    last->ready = TRUE;
    if (!channel->next) {
        EXIT_IF(channel->last);
        channel->next = last;
        channel->last = last;
        return;
    }
    channel->last->next = last;
    channel->last = last;
}

Bool channel_ready(Channel*);
Bool channel_ready(Channel* channel) {
#if DEBUG
    printf("  [ Channel ready? ]\n");
#endif
    EXIT_IF(!channel);
    if (channel->ready && channel->waiting) {
        pop_waiting(channel);
    }
    return channel->ready;
}

static Waiting* new_waiting(void) {
#if DEBUG
    printf("  [ Creating wait list ]\n");
#endif
    EXIT_IF(CAP_WAITING <= LEN_WAITING);
    Waiting* waiting = &WAITING[LEN_WAITING++];
    waiting->thread = NULL;
    waiting->next = NULL;
    waiting->last = NULL;
    return waiting;
}

void push_waiting(Channel*, Thread*);
void push_waiting(Channel* channel, Thread* thread) {
    EXIT_IF(!channel);
    EXIT_IF(!thread);
#if DEBUG
    printf("  [ Adding thread (%p) to wait list ]\n", (void*)thread);
#endif
    Waiting* waiting = new_waiting();
    waiting->thread = thread;
    if (!channel->waiting) {
        channel->waiting = waiting;
        return;
    }
    if (!channel->waiting->next) {
        EXIT_IF(channel->waiting->last);
        channel->waiting->next = waiting;
        channel->waiting->last = waiting;
        return;
    }
    channel->waiting->last->next = waiting;
    channel->waiting->last = waiting;
}

void* pop_channel(Channel*);
void* pop_channel(Channel* channel) {
#if DEBUG
    printf("  [ Popping from channel ]\n");
#endif
    EXIT_IF(!channel);
    if (!channel->ready) {
        EXIT_IF(channel->next);
        EXIT_IF(channel->last);
        return NULL;
    }
    Channel* next = channel->next;
    void*    data = channel->data;
    if (!next) {
        EXIT_IF(channel->last);
        channel->ready = FALSE;
        channel->data = NULL;
        return data;
    }
    channel->ready = next->ready;
    channel->data = next->data;
    if (next == channel->last) {
        EXIT_IF(next->next);
        channel->next = NULL;
        channel->last = NULL;
        return data;
    }
    channel->next = next->next;
    return data;
}

void pause_thread(Thread*);
void pause_thread(Thread* thread) {
#if DEBUG
    printf("  [ Pausing thread ]\n");
#endif
    thread->status = PAUSED;
}

static void vacuum_queue(void) {
#if DEBUG
    printf("  [ Vacuuming queue ]\n");
#endif
    EXIT_IF(!QUEUE);
    for (;;) {
        if (!QUEUE) {
#if DEBUG
            printf("  [ Queue is empty ]\n");
#endif
            _exit(ERROR);
        }
        if (QUEUE->status != DEAD) {
            break;
        }
        QUEUE = QUEUE->next;
    }
    {
        Thread* current = QUEUE;
        Thread* next = current->next;
        Thread* last;
        for (;;) {
            current->next = next;
            if (!next) {
                last = current;
                break;
            }
            if (next->status != DEAD) {
                current = next;
            }
            next = next->next;
        }
        QUEUE->last = last;
    }
    for (Thread* thread = QUEUE; thread; thread = thread->next) {
        if (thread->status == READY) {
            return;
        }
    }
#if DEBUG
    printf("  [ Deadlock ]\n");
#endif
    _exit(ERROR);
}

void scheduler(void);
void scheduler(void) {
#if DEBUG
    printf("  [ Resuming scheduler ]\n");
#endif
    if (THREADS[0].status == DEAD) {
#if DEBUG
        printf("  [ Main thread is dead ]\n"
               "  [ Scheduler finished, %u thread(s) still alive ]\n",
               LEN_THREADS - FINISHED);
#endif
        _exit(OK);
    }
    vacuum_queue();
#if DEBUG
    for (Thread* thread = QUEUE; thread; thread = thread->next) {
        printf("    > %p\n", (void*)thread);
    }
#endif
    {
        if (!QUEUE->next) {
            EXIT_IF(QUEUE->status != READY);
            CURRENT_THREAD = QUEUE;
            QUEUE->next = NULL;
            QUEUE->last = NULL;
        } else {
            do {
                Thread* last = QUEUE->last;
                CURRENT_THREAD = QUEUE;
                QUEUE = QUEUE->next;
                if (QUEUE->next) {
                    QUEUE->last = last;
                } else {
                    QUEUE->last = NULL;
                }
                CURRENT_THREAD->next = NULL;
                CURRENT_THREAD->last = NULL;
                push_thread(QUEUE, CURRENT_THREAD);
            } while (CURRENT_THREAD->status != READY);
        }
    }
#if DEBUG
    for (Thread* thread = QUEUE; thread; thread = thread->next) {
        printf("    < %p\n", (void*)thread);
    }
    printf("  [ Running thread (%p) ]\n", (void*)CURRENT_THREAD);
#endif
    CURRENT_THREAD->resume();
}
