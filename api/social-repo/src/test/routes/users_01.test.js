import request from 'supertest';

import app from '../../app.mjs';
import UserRepo from "../../repositories/user-repository.mjs";

import { Context } from '../../utilities/db-utility.mjs';

// set up the context with role and schema
let context = null;
beforeAll(async () => {
    context = await Context.setUp();
});
// tear down the context with role and schema
afterAll(() => {
    return context.cleanUp();
})
// remove all data sets of previous tests
afterEach(() => {
    return UserRepo.deleteAll();
});

it('create a user', async () => {
    const start = await UserRepo.count();
    expect(start).toEqual(0);

    const { text } = await request(app.init())
    .post('/users')
    .send({username: 'Bill', bio: 'Test bio'})
    .expect(200);
    const {id, username, bio} = JSON.parse(text);

    const afterCreate = await UserRepo.count();
    expect(afterCreate - start).toEqual(1);

    expect(username).toEqual('Bill');
    expect(bio).toEqual('Test bio');
});


it('create another user and find by id', async () => {
    const start = await UserRepo.count();
    expect(start).toEqual(0);

    const { text } = await request(app.init())
    .post('/users')
    .send({username: 'James', bio: 'Another test bio'})
    .expect(200);
    const {id, username, bio} = JSON.parse(text);

    const afterCreate = await UserRepo.count();
    expect(afterCreate - start).toEqual(1);

    expect(username).toEqual('James');
    expect(bio).toEqual('Another test bio');

    const user = await UserRepo.findById(id);
    expect(user.username).toEqual('James');
});
