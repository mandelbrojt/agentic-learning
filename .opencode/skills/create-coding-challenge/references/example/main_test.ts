import { describe, it, assert, withSubmit } from "./unit_test";
import type { CustomerMessage } from "./utils";
import { parseCustomerMessage } from "./utils";

type TestCase = {
  input: unknown;
  expected: CustomerMessage;
};

const emailMessage = `Hello?
I need some help.
Do you know how to fix my printer?`;

const chatMessages = ["Hi", "In case you don't know...", "YOUR PRODUCT SUCKS"];

const chatMessagesConcat = `Hi
In case you don't know...
YOUR PRODUCT SUCKS`;

describe("parseCustomerMessage", () => {
  const runCases: TestCase[] = [
    {
      input: emailMessage,
      expected: {
        content: emailMessage,
        source: "email",
      },
    },
    {
      input: chatMessages,
      expected: {
        content: chatMessagesConcat,
        source: "chat",
      },
    },
  ];

  const submitCases = runCases.concat([
    {
      input: {
        hiddenMessage:
          "Through the darkness of future's past, the magician longs to see.",
      },
      expected: {
        content: "",
        source: "unknown",
      },
    },
  ]);

  let testCases = runCases;
  if (withSubmit) {
    testCases = submitCases;
  }

  for (let i = 0; i < testCases.length; i++) {
    const { input, expected } = testCases[i];
    it(`Test ${i + 1}: ${JSON.stringify(input)}`, () => {
      const actual = parseCustomerMessage(input);
      assert.strictEqual(actual.content, expected.content);
      assert.strictEqual(actual.source, expected.source);
    });
  }

  const numSkipped = submitCases.length - testCases.length;
  if (numSkipped > 0) {
    console.log(`- Skip: ${numSkipped} test case(s) for submit`);
  }
});

