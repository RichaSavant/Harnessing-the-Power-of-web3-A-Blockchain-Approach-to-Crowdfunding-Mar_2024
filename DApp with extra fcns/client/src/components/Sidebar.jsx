import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';

import { logo, sun, Tokenkhan } from '../assets';
import { navlinks } from '../constants';

const Icon = ({ styles, name, imgUrl, isActive, disabled, handleClick }) => (
  <div className={`${isActive && isActive === name} ${!disabled && 'cursor-pointer'} ${styles}`} onClick={handleClick}>
    <span className="inline-flex justify-center items-center">
        {!isActive ? (
            <img src={imgUrl} alt="fund_logo" className="w-1/2 h-1/2" />
        ) : (
            <div>
                <img src={imgUrl} alt="fund_logo" className='inline-flex ml-3' />
                <span className="ml-5 text-sm tracking-wide truncate">{name}</span>
            </div>
        )}
    </span>
  </div>
)

const Sidebar = () => {
  const navigate = useNavigate();
  const [isActive, setIsActive] = useState('Home');

  const desiredLinks = [
    { id: 'home', name: 'Home', link: '/', imgUrl: logo },
    { id: 'create_campaign', name: 'Create Campaign', link: '/create-campaign', imgUrl: logo },
    { id: 'profile', name: 'Profile', link: '/profile', imgUrl: logo },
  ];

  return (
    <div className="flex justify-between items-center flex-col sticky top-5 h-[93vh]">
      <div className="min-h-screen flex flex-col flex-auto flex-shrink-0 antialiased bg-black text-white">
        <div className="fixed flex flex-col top-0 left-0 w-21 bg-black h-full border-r border-gray-700">
          <div className="flex items-center justify-center h-14 border-b border-gray-700 mt-10">
            <Link to="/">
              <Icon styles={"w-24 md:w-auto"} imgUrl={Tokenkhan} />
            </Link>
          </div>
          <div className="overflow-y-auto overflow-x-hidden flex-grow mt-10">
            <ul className="flex flex-col py-4 space-y-1">
              {desiredLinks.map((link, index) => (
                <li key={index}>
                  <Icon
                    key={link.id}
                    {...link}
                    isActive={isActive}
                    name={link.name}
                    styles={"relative flex flex-row items-center h-11 focus:outline-none hover:bg-gray-800 text-white hover:text-gray-300 border-l-4 border-transparent hover:border-indigo-500 pr-6"}
                    handleClick={() => {
                      if(!link.disabled) {
                        setIsActive(link.name);
                        navigate(link.link);
                      }
                    }}
                  />
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Sidebar;
