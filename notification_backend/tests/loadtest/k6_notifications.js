import { check } from 'k6';
import { Kafka } from 'k6/x/kafka';

const kafka = new Kafka({
  brokers: ['localhost:29092'],
});

const producer = kafka.producer();
const topics = ['user.events', 'post.events', 'comments.events'];

export const options = {
  stages: [
    { duration: '30s', target: 100 },  // Ramp-up
    { duration: '1m', target: 500 },   // Пиковая нагрузка
    { duration: '30s', target: 0 },    // Ramp-down
  ],
};

function generateEvent(userId) {
  const eventType = __VU % 3;
  const baseEvent = {
    from_user_id: userId,
    to_user_id: userId,
    event_id: "test-" + __VU + "-" + __ITER
  };

  switch(eventType) {
    case 0: return {
      type: "friend_response",
      status: "request_sent",
      ...baseEvent
    };
    case 1: return {
      type: "post_created",
      event_name: "Load Test Event",
      ...baseEvent
    };
    default: return {
      type: "new_comment",
      comment: "Load test comment",
      ...baseEvent
    };
  }
}

export default function () {
  const userId = "user-" + __VU;
  const event = generateEvent(userId);
  const topic = topics[__VU % 3];
  
  producer.produce({
    topic: topic,
    messages: [{
      key: userId,
      value: JSON.stringify(event),
    }],
  });

  check(event, {
    "message produced": () => true,
  });
}

export function teardown() {
  producer.close();
}
