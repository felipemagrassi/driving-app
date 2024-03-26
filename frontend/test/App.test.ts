import { mount } from "@vue/test-utils";
import AppVue from "../src/App.vue";

test("Must create a passager", async function () {
  const wrapper = mount(AppVue, {});

  expect(wrapper.get(".signup-title").text()).toBe("Signup");
  wrapper.get('.signup-name').setValue("Felipe Magrassi");
  wrapper.get('.signup-email').setValue("felipe.magrassi@email.com");
  wrapper.get('.signup-cpf').setValue("95818705552");
  wrapper.get('.signup-is-passenger').setValue(true)
  wrapper.get('.signup-is-driver').setValue(false)
  await wrapper.get('.signup-submit').trigger('click')

  expect(wrapper.get('.signup-account-id').text()).toBeDefined();
});
